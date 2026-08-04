local V = ...

local Voxel3D = V.require("Voxel3D")
local Budget = V.require("BuildBudget")

local MonRelief = {}

MonRelief.SHADE = { front = 1.0, back = 0.68, side = 0.78,
                    top = 0.94, bottom = 0.55 }

local CUT = 0.5
local MAX_QUADS = 6144
local MIN_INK = 32
local INSET = 0.02
local MAX_DEPTH = 48

local cache = {}

local function readBack(tex)
  if not (tex and love.graphics and love.graphics.newCanvas) then return nil end
  local w, h = tex:getDimensions()
  if not (w and h and w > 0 and h > 0) then return nil end
  local prevCanvas = love.graphics.getCanvas()
  local prevBlend, prevAlpha = love.graphics.getBlendMode()
  local pr, pg, pb, pa = love.graphics.getColor()
  local data = nil
  local ok = pcall(function()
    local canvas = love.graphics.newCanvas(w, h)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("replace", "premultiplied")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(tex, 0, 0)
    love.graphics.setCanvas()
    data = canvas:newImageData()
    if canvas.release then pcall(canvas.release, canvas) end
  end)
  if prevCanvas then
    love.graphics.setCanvas(prevCanvas)
  else
    love.graphics.setCanvas()
  end
  love.graphics.setBlendMode(prevBlend or "alpha", prevAlpha)
  love.graphics.setColor(pr or 1, pg or 1, pb or 1, pa or 1)
  return ok and data or nil
end

local function build(tex)
  local data = readBack(tex)
  if not data then return nil end
  local w, h = data:getDimensions()

  local ink = {}
  local x0, y0, x1, y1, n = w, h, -1, -1, 0
  for y = 0, h - 1 do
    Budget.tick()
    for x = 0, w - 1 do
      local _, _, _, a = data:getPixel(x, y)
      if a > CUT then
        ink[y * w + x] = true
        n = n + 1
        if x < x0 then x0 = x end
        if x > x1 then x1 = x end
        if y < y0 then y0 = y end
        if y > y1 then y1 = y end
      end
    end
  end
  if n < MIN_INK or x1 < x0 then return nil end

  local z0, z1 = {}, {}
  for y = y0, y1 do
    Budget.tick()
    local lo, hi = nil, nil
    for x = x0, x1 do
      if ink[y * w + x] then
        lo = lo or x
        hi = x
      end
    end
    if lo then
      local c = (lo + hi + 1) / 2
      local hw = (hi - lo + 1) / 2
      for x = lo, hi do
        local i = y * w + x
        if ink[i] then
          local dx = x + 0.5 - c
          local d = 1
          if hw * hw > dx * dx then
            d = math.floor(2 * math.sqrt(hw * hw - dx * dx) + 0.5)
            if d < 1 then d = 1 end
            if d > MAX_DEPTH then d = MAX_DEPTH end
          end
          z0[i] = -math.floor(d / 2)
          z1[i] = z0[i] + d
        end
      end
    end
  end

  local function solid(x, y)
    return z0[y * w + x] ~= nil
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

  local function card(x, y)
    return x / w - 0.5, 1 - y / h
  end

  local function uv(x, y)
    return (x + INSET) / w, (x + 1 - INSET) / w,
           (y + INSET) / h, (y + 1 - INSET) / h
  end

  local SH = MonRelief.SHADE
  local kz = 1 / w

  for y = y0, y1 do
    Budget.tick()
    local x = x0
    while x <= x1 do
      local i = y * w + x
      if z0[i] and quads < MAX_QUADS then
        local run = x
        while run + 1 <= x1 do
          local j = y * w + run + 1
          if z0[j] == z0[i] and z1[j] == z1[i] then run = run + 1 else break end
        end
        local ax0, ay0 = card(x, y)
        local ax1, ay1 = card(run + 1, y + 1)
        local u0 = (x + INSET) / w
        local u1 = (run + 1 - INSET) / w
        local v0 = (y + INSET) / h
        local v1 = (y + 1 - INSET) / h
        local fz, bz = z1[i] * kz, z0[i] * kz

        push({ { ax0, ay1, fz }, { ax1, ay1, fz },
               { ax1, ay0, fz }, { ax0, ay0, fz } },
             { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH.front)
        push({ { ax1, ay1, bz }, { ax0, ay1, bz },
               { ax0, ay0, bz }, { ax1, ay0, bz } },
             { { u1, v1 }, { u0, v1 }, { u0, v0 }, { u1, v0 } }, SH.back)
        x = run + 1
      else
        x = x + 1
      end
    end
  end

  for y = y0, y1 do
    Budget.tick()
    for x = x0, x1 do
      local i = y * w + x
      if z0[i] and quads < MAX_QUADS then
        local ax0, ay0 = card(x, y)
        local ax1, ay1 = card(x + 1, y + 1)
        local u0, u1, v0, v1 = uv(x, y)
        local fz, bz = z1[i] * kz, z0[i] * kz

        if not solid(x - 1, y) then
          push({ { ax0, ay1, bz }, { ax0, ay1, fz },
                 { ax0, ay0, fz }, { ax0, ay0, bz } },
               { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH.side)
        end
        if not solid(x + 1, y) then
          push({ { ax1, ay1, fz }, { ax1, ay1, bz },
                 { ax1, ay0, bz }, { ax1, ay0, fz } },
               { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH.side)
        end
        if not solid(x, y - 1) then
          push({ { ax0, ay0, bz }, { ax1, ay0, bz },
                 { ax1, ay0, fz }, { ax0, ay0, fz } },
               { { u0, v0 }, { u1, v0 }, { u1, v1 }, { u0, v1 } }, SH.top)
        end
        if not solid(x, y + 1) then
          push({ { ax0, ay1, fz }, { ax1, ay1, fz },
                 { ax1, ay1, bz }, { ax0, ay1, bz } },
               { { u0, v1 }, { u1, v1 }, { u1, v0 }, { u0, v0 } }, SH.bottom)
        end
      end
    end
  end

  if quads == 0 then return nil end
  return Voxel3D.newMesh(verts, indices)
end

function MonRelief.mesh(tex, key)
  if not (tex and key) then return nil end
  if cache[key] == nil then
    local ok, mesh = pcall(build, tex)
    cache[key] = (ok and mesh) or false
  end
  return cache[key] or nil
end

function MonRelief.invalidate()
  for _, mesh in pairs(cache) do
    if mesh and mesh.release then pcall(mesh.release, mesh) end
  end
  cache = {}
end

return MonRelief
