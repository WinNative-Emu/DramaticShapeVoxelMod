local V = ...

local Assets = require("src.render.Assets")
local Voxel3D = V.require("Voxel3D")
local Budget = V.require("BuildBudget")

local ActorHull = {}

ActorHull.SIZE = 16

ActorHull.SHADE = {
  [1] = 0.80,
  [2] = 0.80,
  [3] = 1.00,
  [4] = 0.55,
  [5] = 1.00,
  [6] = 0.72,
}

local MAX_QUADS = 4096
local MIN_VOXELS = 24
local INSET = 0.02

local POSES = {
  stand = { front = 0, back = 1, side = 2 },
  walk = { front = 3, back = 4, side = 5 },
}

local NEIGHBOURS = {
  { 1, 0, 0 }, { -1, 0, 0 }, { 0, 1, 0 },
  { 0, -1, 0 }, { 0, 0, 1 }, { 0, 0, -1 },
}

local hulls = {}
local sheets = {}

local function sheetData(path)
  if sheets[path] == nil then
    local ok, data = pcall(Assets.imageData, path)
    sheets[path] = (ok and data and data.getPixel) and data or false
  end
  return sheets[path] or nil
end

local function frameCount(def)
  local n = tonumber(def and def.frames) or 1
  if n < 1 then return 1 end
  return math.floor(n)
end

function ActorHull.poseFor(def, frame)
  if frameCount(def) < 6 then return "stand" end
  return (tonumber(frame) or 0) >= 3 and "walk" or "stand"
end

local function frameRows(def, pose)
  local n = frameCount(def)
  local slots = POSES[pose] or POSES.stand
  if slots.front >= n then slots = POSES.stand end
  local front, back, side = slots.front, slots.back, slots.side
  if back >= n then back = nil end
  if side >= n then side = nil end
  return front, back, side
end

local function opaqueAt(data, row, x, y, w, h)
  local px, py = x, row * 16 + y
  if px < 0 or py < 0 or px >= w or py >= h then return false end
  local r, _, _, a = data:getPixel(px, py)
  if a <= 0 then return false end
  return r <= 0.83
end

local function darkAt(data, row, x, y, w, h)
  local px, py = x, row * 16 + y
  if px < 0 or py < 0 or px >= w or py >= h then return false end
  local r, _, _, a = data:getPixel(px, py)
  return a > 0 and r <= 0.17
end

local function viewOf(data, row, w, h)
  local N = ActorHull.SIZE
  local view, dark, lo, hi, n = {}, {}, {}, {}, 0
  for y = 0, N - 1 do
    for x = 0, N - 1 do
      if opaqueAt(data, row, x, y, w, h) then
        view[y * N + x] = true
        if darkAt(data, row, x, y, w, h) then dark[y * N + x] = true end
        lo[y] = lo[y] or x
        hi[y] = x
        n = n + 1
      end
    end
  end
  view.dark = dark
  view.lo = lo
  view.hi = hi
  return view, n
end

local function largestComponent(solid, N)
  local seen, best, bestSize = {}, nil, 0
  local stack = {}
  for key in pairs(solid) do
    if not seen[key] then
      local comp, size, top = {}, 0, 1
      stack[1] = key
      seen[key] = true
      while top > 0 do
        local at = stack[top]
        top = top - 1
        comp[at] = true
        size = size + 1
        local ix = at % N
        local iy = math.floor(at / N) % N
        local iz = math.floor(at / (N * N))
        for _, d in ipairs(NEIGHBOURS) do
          local nx, ny, nz = ix + d[1], iy + d[2], iz + d[3]
          if nx >= 0 and ny >= 0 and nz >= 0
             and nx < N and ny < N and nz < N then
            local nk = nz * N * N + ny * N + nx
            if solid[nk] and not seen[nk] then
              seen[nk] = true
              top = top + 1
              stack[top] = nk
            end
          end
        end
      end
      if size > bestSize then best, bestSize = comp, size end
      Budget.tick()
    end
  end
  return best or {}, bestSize
end

local function carve(def, pose)
  local path = def and def.image
  if type(path) ~= "string" then return nil end
  local data = sheetData(path)
  if not data then return nil end
  local sheetW, sheetH = data:getDimensions()
  if not (sheetW and sheetH and sheetW > 0 and sheetH > 0) then return nil end

  local N = ActorHull.SIZE
  local frontRow, backRow, sideRow = frameRows(def, pose)
  local front, frontN = viewOf(data, frontRow, sheetW, sheetH)
  if frontN == 0 then return nil end
  local back = backRow and viewOf(data, backRow, sheetW, sheetH) or nil
  local side = sideRow and viewOf(data, sideRow, sheetW, sheetH) or nil

  local depthView = side or front
  local solid, count = {}, 0
  for y = 0, N - 1 do
    Budget.tick()
    local rowBase = y * N
    for x = 0, N - 1 do
      local outline = front[rowBase + x]
                      or (back and back[rowBase + (N - 1 - x)])
      if outline then
        for z = 0, N - 1 do
          local depth = depthView[rowBase + z]
          if depth then
            solid[z * N * N + rowBase + x] = true
            count = count + 1
          end
        end
      end
    end
  end
  if count < MIN_VOXELS then return nil end

  local body, bodyCount = largestComponent(solid, N)
  if bodyCount < MIN_VOXELS then return nil end

  local function at(x, y, z)
    if x < 0 or y < 0 or z < 0 or x >= N or y >= N or z >= N then
      return false
    end
    return body[z * N * N + y * N + x] and true or false
  end

  local function uv(row, tx, ty)
    return (tx + INSET) / sheetW, (tx + 1 - INSET) / sheetW,
           (row * 16 + ty + INSET) / sheetH,
           (row * 16 + ty + 1 - INSET) / sheetH
  end

  local function flankTexel(view, tx, y)
    local lo, hi = view.lo[y], view.hi[y]
    if not lo then return tx end
    local dir = (tx + tx < lo + hi) and 1 or -1
    for step = 0, 3 do
      local t = tx + dir * step
      local i = y * N + t
      if t < 0 or t > N - 1 or not view[i] then break end
      if not view.dark[i] then return t end
    end
    return tx
  end

  local function capTexel(view, x, y)
    for y2 = y + 1, math.min(N - 1, y + 3) do
      local i = y2 * N + x
      if view[i] and not view.dark[i] then return y2 end
    end
    return y
  end

  local verts, indices, quads = {}, {}, 0
  local function push(c, uvs, shade)
    for k = 1, 4 do
      local p, t = c[k], uvs[k]
      verts[#verts + 1] = { p[1], p[2], p[3], t[1], t[2], shade }
    end
    Voxel3D.pushQuad(indices, quads)
    quads = quads + 1
  end

  local SH = ActorHull.SHADE
  local sideOwn = sideRow ~= nil

  for z = 0, N - 1 do
    Budget.tick()
    for y = 0, N - 1 do
      for x = 0, N - 1 do
        if at(x, y, z) and quads < MAX_QUADS then
          local mx, my, mz = x, N - 1 - y, N - 1 - z

          if not at(x, y, z - 1) then
            local u0, u1, v0, v1 = uv(frontRow, x, y)
            push({ { mx, my, mz + 1 }, { mx + 1, my, mz + 1 },
                   { mx + 1, my + 1, mz + 1 }, { mx, my + 1, mz + 1 } },
                 { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH[5])
          end
          if not at(x, y, z + 1) then
            local u0, u1, v0, v1 = uv(backRow or frontRow,
                                      backRow and (N - 1 - x) or x, y)
            push({ { mx + 1, my, mz }, { mx, my, mz },
                   { mx, my + 1, mz }, { mx + 1, my + 1, mz } },
                 { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH[6])
          end
          if not at(x + 1, y, z) then
            local u0, u1, v0, v1 = uv(sideRow or frontRow,
                                      sideOwn and flankTexel(side, z, y)
                                              or flankTexel(front, x, y), y)
            push({ { mx + 1, my, mz + 1 }, { mx + 1, my, mz },
                   { mx + 1, my + 1, mz }, { mx + 1, my + 1, mz + 1 } },
                 { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH[1])
          end
          if not at(x - 1, y, z) then
            local u0, u1, v0, v1 = uv(sideRow or frontRow,
                                      sideOwn and flankTexel(side, z, y)
                                              or flankTexel(front, x, y), y)
            push({ { mx, my, mz }, { mx, my, mz + 1 },
                   { mx, my + 1, mz + 1 }, { mx, my + 1, mz } },
                 { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH[2])
          end
          if not at(x, y - 1, z) then
            local u0, u1, v0, v1 = uv(frontRow, x, capTexel(front, x, y))
            push({ { mx, my + 1, mz }, { mx + 1, my + 1, mz },
                   { mx + 1, my + 1, mz + 1 }, { mx, my + 1, mz + 1 } },
                 { { u0, v0 }, { u1, v0 }, { u1, v1 }, { u0, v1 } }, SH[3])
          end
          if not at(x, y + 1, z) then
            local u0, u1, v0, v1 = uv(frontRow, x, y)
            push({ { mx, my, mz + 1 }, { mx + 1, my, mz + 1 },
                   { mx + 1, my, mz }, { mx, my, mz } },
                 { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH[4])
          end
        end
      end
    end
  end

  if quads == 0 then return nil end
  return verts, indices, quads, bodyCount
end

function ActorHull.geometry(def, pose)
  return carve(def, pose or "stand")
end

function ActorHull.mesh(def, frame)
  if not (def and type(def.image) == "string") then return nil end
  local pose = ActorHull.poseFor(def, frame)
  local key = def.image .. "#" .. pose
  if hulls[key] == nil then
    local ok, verts, indices = pcall(carve, def, pose)
    local mesh = nil
    if ok and verts then mesh = Voxel3D.newMesh(verts, indices) end
    hulls[key] = mesh or false
  end
  return hulls[key] or nil
end

function ActorHull.invalidate()
  for _, mesh in pairs(hulls) do
    if mesh and mesh.release then pcall(mesh.release, mesh) end
  end
  hulls = {}
  sheets = {}
end

Assets.register(ActorHull.invalidate)

return ActorHull
