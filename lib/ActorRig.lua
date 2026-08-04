local V = ...

local Voxel3D = V.require("Voxel3D")
local Budget = V.require("BuildBudget")
local RigSpecs = V.require("RigSpecs")

local ActorRig = {}

ActorRig.SIZE = 44

local MAX_VERTS = 12000
local TEX = 128
local FACE = 96
local PAL_Y0 = 96
local PAL_N = (TEX - PAL_Y0) * TEX
local SMOOTH_ROUNDS = 3
local SMOOTH_W = 0.50

local PARTS = { "hat", "peak", "hair", "head", "neck", "hand", "arm",
                "collar", "coat", "torso", "shoe", "leg" }
local PART_ID = {}
for i, name in ipairs(PARTS) do PART_ID[name] = i end

local VOID = -1e9

local rigs = {}
local scratch = nil
local scratch2 = nil
local field = nil
local best = nil
local pid = nil

local sqrt, floor, min, max, abs = math.sqrt, math.floor, math.min,
                                   math.max, math.abs

local function ensureBuffers(n)
  local cells = (n + 1) * (n + 1) * (n + 1)
  if field and #field == cells then return cells end
  field, best, pid, scratch, scratch2 = {}, {}, {}, {}, {}
  for i = 1, cells do
    field[i] = VOID
    best[i] = VOID
    pid[i] = 0
    scratch[i] = VOID
    scratch2[i] = VOID
  end
  return cells
end

local function smax(a, b, k)
  local h = 0.5 + 0.5 * (a - b) / k
  if h < 0 then h = 0 elseif h > 1 then h = 1 end
  return b + (a - b) * h + k * h * (1 - h)
end

local function ss(e0, e1, x)
  local d = e1 - e0
  if abs(d) < 1e-6 then d = (d >= 0) and 1e-6 or -1e-6 end
  local t = (x - e0) / d
  if t < 0 then t = 0 elseif t > 1 then t = 1 end
  return t * t * (3 - 2 * t)
end

local function fillEllipsoid(g, n, cx, cy, cz, rx, ry, rz)
  local rmin = min(rx, min(ry, rz))
  local half = n / 2
  local i = 0
  for z = 0, n do
    local dz = (z + 0.5 - half - cz) / rz
    local dz2 = dz * dz
    for y = 0, n do
      local dy = (y + 0.5 - cy) / ry
      local dyz = dy * dy + dz2
      for x = 0, n do
        local dx = (x + 0.5 - half - cx) / rx
        i = i + 1
        g[i] = (1 - sqrt(dx * dx + dyz)) * rmin
      end
    end
    Budget.tick()
  end
end

local function fillCapsule(g, n, ax, ay, az, bx, by, bz, r0, r1)
  local ux, uy, uz = bx - ax, by - ay, bz - az
  local L2 = ux * ux + uy * uy + uz * uz
  if L2 <= 0 then L2 = 1e-6 end
  local half = n / 2
  local i = 0
  for z = 0, n do
    local pz = z + 0.5 - half
    for y = 0, n do
      local py = y + 0.5
      for x = 0, n do
        local px = x + 0.5 - half
        i = i + 1
        local t = ((px - ax) * ux + (py - ay) * uy + (pz - az) * uz) / L2
        if t < 0 then t = 0 elseif t > 1 then t = 1 end
        local qx = px - (ax + t * ux)
        local qy = py - (ay + t * uy)
        local qz = pz - (az + t * uz)
        g[i] = (r0 + (r1 - r0) * t) - sqrt(qx * qx + qy * qy + qz * qz)
      end
    end
    Budget.tick()
  end
end

local function clipBelow(g, cells, n, yv)
  local i = 0
  for z = 0, n do
    for y = 0, n do
      local d = (y + 0.5) - yv
      for x = 0, n do
        i = i + 1
        if d < g[i] then g[i] = d end
      end
    end
  end
end

local function clipFrontOf(g, cells, n, zv, sign)
  local half = n / 2
  local i = 0
  for z = 0, n do
    local d = ((z + 0.5 - half) - zv) * sign
    for y = 0, n do
      for x = 0, n do
        i = i + 1
        if d < g[i] then g[i] = d end
      end
    end
  end
end

local function subtractInto(g, other, cells)
  for i = 1, cells do
    local d = -other[i]
    if d < g[i] then g[i] = d end
  end
end

local function unionInto(g, other, cells)
  for i = 1, cells do
    if other[i] > g[i] then g[i] = other[i] end
  end
end

local function mergeInto(cells, g, id, k, first)
  for i = 1, cells do
    local b = g[i]
    if id and b > best[i] then
      best[i] = b
      pid[i] = id
    end
    if first then
      field[i] = b
    else
      field[i] = smax(field[i], b, k)
    end
  end
  Budget.tick()
end

local CORNER = {
  { 0, 0, 0 }, { 1, 0, 0 }, { 0, 1, 0 }, { 1, 1, 0 },
  { 0, 0, 1 }, { 1, 0, 1 }, { 0, 1, 1 }, { 1, 1, 1 },
}
local EDGES = {
  { 1, 2 }, { 1, 3 }, { 1, 5 }, { 2, 4 }, { 2, 6 }, { 3, 4 },
  { 3, 7 }, { 4, 8 }, { 5, 6 }, { 5, 7 }, { 6, 8 }, { 7, 8 },
}

local function surfaceNets(n)
  local stride = n + 1
  local slab = stride * stride
  local index = {}
  local vx, vy, vz = {}, {}, {}
  local count = 0
  local vals = {}

  for k = 0, n - 1 do
    Budget.tick()
    for j = 0, n - 1 do
      local rowBase = k * slab + j * stride + 1
      for i = 0, n - 1 do
        local base = rowBase + i
        local anyIn, allIn = false, true
        for c = 1, 8 do
          local o = CORNER[c]
          local vqq = field[base + o[1] + o[2] * stride + o[3] * slab]
          vals[c] = vqq
          if vqq > 0 then anyIn = true else allIn = false end
        end
        if anyIn and not allIn and count < MAX_VERTS then
          local ax, ay, az, m = 0, 0, 0, 0
          for e = 1, 12 do
            local ea, eb = EDGES[e][1], EDGES[e][2]
            local va, vb = vals[ea], vals[eb]
            if (va > 0) ~= (vb > 0) then
              local d = va - vb
              local t = (d ~= 0) and (va / d) or 0.5
              local pa, pb = CORNER[ea], CORNER[eb]
              ax = ax + pa[1] + (pb[1] - pa[1]) * t
              ay = ay + pa[2] + (pb[2] - pa[2]) * t
              az = az + pa[3] + (pb[3] - pa[3]) * t
              m = m + 1
            end
          end
          if m > 0 then
            count = count + 1
            vx[count] = i + ax / m
            vy[count] = j + ay / m
            vz[count] = k + az / m
            index[k * slab + j * stride + i + 1] = count
          end
        end
      end
    end
  end
  return index, vx, vy, vz, count
end

local function buildQuads(n, index)
  local stride = n + 1
  local slab = stride * stride
  local quads = {}
  local qn = 0
  for k = 0, n - 1 do
    Budget.tick()
    for j = 0, n - 1 do
      for i = 0, n - 1 do
        local base = k * slab + j * stride + i + 1
        local here = field[base] > 0
        if i < n - 1 then
          local there = field[base + 1] > 0
          if here ~= there and j > 0 and k > 0 then
            local a = index[base]
            local b = index[base - stride]
            local c = index[base - stride - slab]
            local d = index[base - slab]
            if a and b and c and d then
              qn = qn + 1
              quads[qn] = here and { a, b, c, d } or { d, c, b, a }
            end
          end
        end
        if j < n - 1 then
          local there = field[base + stride] > 0
          if here ~= there and i > 0 and k > 0 then
            local a = index[base]
            local b = index[base - slab]
            local c = index[base - slab - 1]
            local d = index[base - 1]
            if a and b and c and d then
              qn = qn + 1
              quads[qn] = here and { a, b, c, d } or { d, c, b, a }
            end
          end
        end
        if k < n - 1 then
          local there = field[base + slab] > 0
          if here ~= there and i > 0 and j > 0 then
            local a = index[base]
            local b = index[base - 1]
            local c = index[base - 1 - stride]
            local d = index[base - stride]
            if a and b and c and d then
              qn = qn + 1
              quads[qn] = here and { a, b, c, d } or { d, c, b, a }
            end
          end
        end
      end
    end
  end
  return quads, qn
end

local function relax(vx, vy, vz, count, quads, qn)
  local nb = {}
  for i = 1, count do nb[i] = {} end
  for q = 1, qn do
    local Q = quads[q]
    for a = 1, 4 do
      local i = Q[a]
      local t = nb[i]
      t[#t + 1] = Q[(a % 4) + 1]
      t[#t + 1] = Q[((a + 2) % 4) + 1]
    end
  end
  for _ = 1, SMOOTH_ROUNDS do
    Budget.tick()
    local ox, oy, oz = {}, {}, {}
    for i = 1, count do
      local t = nb[i]
      local m = #t
      if m == 0 then
        ox[i], oy[i], oz[i] = vx[i], vy[i], vz[i]
      else
        local sx, sy, sz = 0, 0, 0
        for j = 1, m do
          local k = t[j]
          sx = sx + vx[k]
          sy = sy + vy[k]
          sz = sz + vz[k]
        end
        ox[i] = vx[i] + (sx / m - vx[i]) * SMOOTH_W
        oy[i] = vy[i] + (sy / m - vy[i]) * SMOOTH_W
        oz[i] = vz[i] + (sz / m - vz[i]) * SMOOTH_W
      end
    end
    vx, vy, vz = ox, oy, oz
  end
  return vx, vy, vz, nb
end

local function sampleField(n, x, y, z)
  local stride = n + 1
  local slab = stride * stride
  local i = floor(x + 0.5)
  local j = floor(y + 0.5)
  local k = floor(z + 0.5)
  if i < 0 then i = 0 elseif i > n then i = n end
  if j < 0 then j = 0 elseif j > n then j = n end
  if k < 0 then k = 0 elseif k > n then k = n end
  return k * slab + j * stride + i + 1
end

local function normalAt(n, x, y, z)
  local stride = n + 1
  local slab = stride * stride
  local base = sampleField(n, x, y, z)
  local i = floor(x + 0.5)
  local j = floor(y + 0.5)
  local k = floor(z + 0.5)
  local gx = (field[base + ((i < n) and 1 or 0)]
              - field[base - ((i > 0) and 1 or 0)])
  local gy = (field[base + ((j < n) and stride or 0)]
              - field[base - ((j > 0) and stride or 0)])
  local gz = (field[base + ((k < n) and slab or 0)]
              - field[base - ((k > 0) and slab or 0)])
  local l = sqrt(gx * gx + gy * gy + gz * gz)
  if l <= 0 then return 0, 1, 0 end
  return -gx / l, -gy / l, -gz / l
end

local function palettise(cols, count)
  local keys = {}
  local pr, pg, pb = {}, {}, {}
  local pn = 0
  local slot = {}
  for i = 1, count do
    local c = cols[i]
    local r = floor(c[1] * 63 + 0.5)
    local g = floor(c[2] * 63 + 0.5)
    local b = floor(c[3] * 63 + 0.5)
    local key = r * 4096 + g * 64 + b
    local at = keys[key]
    if not at then
      if pn < PAL_N then
        pn = pn + 1
        pr[pn], pg[pn], pb[pn] = r / 63, g / 63, b / 63
        keys[key] = pn
        at = pn
      else
        local bestD, bestI = 1e9, 1
        for p = 1, pn do
          local dr = pr[p] - c[1]
          local dg = pg[p] - c[2]
          local db = pb[p] - c[3]
          local d = dr * dr + dg * dg + db * db
          if d < bestD then bestD, bestI = d, p end
        end
        keys[key] = bestI
        at = bestI
      end
    end
    slot[i] = at
  end
  return slot, pr, pg, pb, pn
end

local function buildTexture(pr, pg, pb, pn, spec, F)
  local ok, data = pcall(love.image.newImageData, TEX, TEX)
  if not ok or not data then return nil end
  local set = data.setPixel
  for p = 1, pn do
    local i = p - 1
    pcall(set, data, i % TEX, PAL_Y0 + floor(i / TEX), pr[p], pg[p], pb[p], 1)
  end
  local TWO_PI = math.pi * 2
  for j = 0, FACE - 1 do
    local lat = (0.5 - (j + 0.5) / FACE) * math.pi
    local cl = math.cos(lat)
    local v = math.sin(lat)
    for i = 0, FACE - 1 do
      local lon = ((i + 0.5) / FACE - 0.5) * TWO_PI
      local u = math.sin(lon) * cl
      local fz = math.cos(lon) * cl
      local c = RigSpecs.faceTexel(spec, F, u, v, fz)
      pcall(set, data, i, j, c[1], c[2], c[3], 1)
    end
    Budget.tick()
  end
  local ok2, img = pcall(love.graphics.newImage, data)
  if not ok2 or not img then return nil end
  pcall(img.setFilter, img, "nearest", "nearest")
  return img
end

local K = {
  smax = smax,
  ss = ss,
  ellipsoid = fillEllipsoid,
  capsule = fillCapsule,
  clipBelow = clipBelow,
  clipFrontOf = clipFrontOf,
  subtract = subtractInto,
  union = unionInto,
}

local function poseFor(def, frame)
  local count = tonumber(def and def.frames) or 1
  if count < 6 then return "stand" end
  return ((tonumber(frame) or 0) >= 3) and "walk" or "stand"
end

local function buildField(spec, n, pose)
  local cells = ensureBuffers(n)
  for i = 1, cells do
    field[i] = VOID
    best[i] = VOID
    pid[i] = 0
  end
  K.cells = cells
  K.tmp = scratch2
  local F = RigSpecs.frame(spec, n)
  local g = scratch
  local order = RigSpecs.parts(spec, F, K, pose)
  for at, part in ipairs(order) do
    part.build(g, n, F, K)
    mergeInto(cells, g, part.id and PART_ID[part.id] or nil,
              part.k or (F.hrx * 0.2), at == 1)
  end
  return F
end

local function build(spec, n, pose)
  local F = buildField(spec, n, pose)
  local index, vx, vy, vz, count = surfaceNets(n)
  if count < 32 then return nil end
  local quads, qn = buildQuads(n, index)
  if qn == 0 then return nil end
  vx, vy, vz = relax(vx, vy, vz, count, quads, qn)

  local cols = {}
  local shades = {}
  local ids = {}
  local stride = n + 1
  local slab = stride * stride
  for i = 1, count do
    local at = sampleField(n, vx[i], vy[i], vz[i])
    ids[i] = pid[at]
    local nx, ny, nz = normalAt(n, vx[i], vy[i], vz[i])
    cols[i] = RigSpecs.colour(spec, F, PARTS[ids[i]] or "torso",
                             vx[i], vy[i], vz[i], nx, ny, nz)
    local s = 0.62 + 0.38 * ny
    if s < 0.45 then s = 0.45 elseif s > 1 then s = 1 end
    shades[i] = s
    if i % 512 == 0 then Budget.tick() end
  end

  local keep = {}
  for _, name in ipairs(RigSpecs.crisp(spec)) do keep[PART_ID[name]] = true end
  local soft = {}
  local nb = {}
  for i = 1, count do nb[i] = {} end
  for q = 1, qn do
    local Q = quads[q]
    for a = 1, 4 do
      local t = nb[Q[a]]
      t[#t + 1] = Q[(a % 4) + 1]
      t[#t + 1] = Q[((a + 2) % 4) + 1]
    end
  end
  for i = 1, count do
    local c = cols[i]
    local t = nb[i]
    if keep[ids[i]] or #t == 0 then
      soft[i] = c
    else
      local r, g, b = 0, 0, 0
      for j = 1, #t do
        local o = cols[t[j]]
        r, g, b = r + o[1], g + o[2], b + o[3]
      end
      local m = #t
      soft[i] = { c[1] * 0.45 + (r / m) * 0.55,
                  c[2] * 0.45 + (g / m) * 0.55,
                  c[3] * 0.45 + (b / m) * 0.55 }
    end
  end

  local tris = {}
  local tn = 0
  for q = 1, qn do
    local Q = quads[q]
    tn = tn + 1
    tris[tn] = { Q[1], Q[2], Q[3] }
    tn = tn + 1
    tris[tn] = { Q[1], Q[3], Q[4] }
  end

  local headId = PART_ID.head
  local pr, pg, pb, pn = {}, {}, {}, 0
  local keys = {}
  local function slotFor(r, g, b)
    local qr = floor(r * 63 + 0.5)
    local qg = floor(g * 63 + 0.5)
    local qb = floor(b * 63 + 0.5)
    local key = qr * 4096 + qg * 64 + qb
    local at = keys[key]
    if at then return at end
    if pn >= PAL_N then return 1 end
    pn = pn + 1
    pr[pn], pg[pn], pb[pn] = qr / 63, qg / 63, qb / 63
    keys[key] = pn
    return pn
  end

  local scale = 16.0 / n
  local half = n / 2
  local TWO_PI = math.pi * 2
  local verts = {}
  local vn = 0
  local headAt = {}

  local function faceUV(i)
    local hx = vx[i] - half
    local hz = vz[i] - half
    local hv = (vy[i] - F.hcy) / F.hry
    if hv < -1 then hv = -1 elseif hv > 1 then hv = 1 end
    local lon = math.atan2(hx, hz)
    local lat = math.asin(hv)
    return ((lon / TWO_PI + 0.5) * FACE + 0.5) / TEX,
           ((0.5 - lat / math.pi) * FACE + 0.5) / TEX
  end

  for i = 1, count do
    if ids[i] == headId then
      local uu, vv = faceUV(i)
      vn = vn + 1
      verts[vn] = { vx[i] * scale, vy[i] * scale, vz[i] * scale, uu, vv,
                    shades[i] }
      headAt[i] = vn
    end
  end

  local map = {}
  local mn = 0
  for t = 1, tn do
    local T = tris[t]
    local a, b, c = T[1], T[2], T[3]
    if headAt[a] and headAt[b] and headAt[c] then
      map[mn + 1] = headAt[a]
      map[mn + 2] = headAt[b]
      map[mn + 3] = headAt[c]
      mn = mn + 3
    else
      local ca, cb, cc = soft[a], soft[b], soft[c]
      local s = slotFor((ca[1] + cb[1] + cc[1]) / 3,
                        (ca[2] + cb[2] + cc[2]) / 3,
                        (ca[3] + cb[3] + cc[3]) / 3) - 1
      local uu = (s % TEX + 0.5) / TEX
      local vv = (PAL_Y0 + floor(s / TEX) + 0.5) / TEX
      for _, k in ipairs(T) do
        vn = vn + 1
        verts[vn] = { vx[k] * scale, vy[k] * scale, vz[k] * scale, uu, vv,
                      shades[k] }
        mn = mn + 1
        map[mn] = vn
      end
    end
    if t % 1024 == 0 then Budget.tick() end
  end

  local tex = buildTexture(pr, pg, pb, pn, spec, F)
  if not tex then return nil end

  local mesh = Voxel3D.newMesh(verts, map)
  if not mesh then return nil end
  return { mesh = mesh, tex = tex, verts = vn, quads = qn }
end

function ActorRig.has(def)
  return RigSpecs.lookup(def and def.image) ~= nil
end

function ActorRig.mesh(def, frame)
  local spec = RigSpecs.lookup(def and def.image)
  if not spec then return nil end
  local pose = poseFor(def, frame)
  local key = spec.key .. "#" .. pose
  if rigs[key] == nil then
    local ok, rig = pcall(build, spec, ActorRig.SIZE, pose)
    rigs[key] = (ok and rig) or false
  end
  local rig = rigs[key]
  if not rig then return nil end
  return rig.mesh, rig.tex
end

function ActorRig.geometry(spec, n, pose)
  return build(spec, n or ActorRig.SIZE, pose or "stand")
end

ActorRig.poseFor = poseFor

function ActorRig.invalidate()
  for _, rig in pairs(rigs) do
    if rig then
      if rig.mesh and rig.mesh.release then pcall(rig.mesh.release, rig.mesh) end
      if rig.tex and rig.tex.release then pcall(rig.tex.release, rig.tex) end
    end
  end
  rigs = {}
  field, best, pid, scratch, scratch2 = nil, nil, nil, nil, nil
end

ActorRig.PARTS = PARTS
ActorRig.PART_ID = PART_ID
ActorRig.toolkit = K

return ActorRig
