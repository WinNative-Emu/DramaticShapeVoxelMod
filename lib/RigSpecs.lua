local V = ...

local RigSpecs = {}

local floor, sqrt, abs = math.floor, math.sqrt, math.abs

local FRAMES = {
  kid = { top = -0.15, bot = 7.45, sh = 9.10, hip = 12.35, foot = 15.60,
          hrx = 3.86, hrz = 3.58, thw = 2.70, thz = 2.05, legr = 1.05,
          legx = 1.30, armt = 9.30, armb = 12.30, armk = 0.30 },
  teen = { top = 0.20, bot = 7.10, sh = 8.80, hip = 12.00, foot = 15.60,
           hrx = 3.65, hrz = 3.40, thw = 2.85, thz = 2.16, legr = 1.06,
           legx = 1.32, armt = 9.00, armb = 12.05, armk = 0.31 },
  adult = { top = 0.55, bot = 6.95, sh = 8.50, hip = 11.70, foot = 15.60,
            hrx = 3.44, hrz = 3.20, thw = 3.00, thz = 2.30, legr = 1.10,
            legx = 1.36, armt = 8.70, armb = 11.90, armk = 0.32 },
  bulk = { top = 0.65, bot = 6.90, sh = 8.35, hip = 11.60, foot = 15.60,
           hrx = 3.36, hrz = 3.14, thw = 3.42, thz = 2.58, legr = 1.22,
           legx = 1.46, armt = 8.55, armb = 11.85, armk = 0.36 },
}

function RigSpecs.frame(spec, n)
  local d = FRAMES[spec.frame or "kid"]
  local s = n / 16.0
  local F = { n = n, s = s }
  F.Y = function(px) return (16.0 - px) * s end
  F.headTop = F.Y(d.top)
  F.headBot = F.Y(d.bot)
  F.hcy = (F.headTop + F.headBot) / 2
  F.hry = (F.headTop - F.headBot) / 2
  F.hrx = d.hrx * s
  F.hrz = d.hrz * s
  F.shY = F.Y(d.sh)
  F.hipY = F.Y(d.hip)
  F.footY = F.Y(d.foot)
  F.thw = d.thw * s
  F.thz = d.thz * s
  F.legr = d.legr * s
  F.legx = d.legx * s
  F.armr = F.thw * d.armk
  F.armx = F.thw + F.armr * 0.86
  F.armt = F.Y(d.armt)
  F.armb = F.Y(d.armb)
  F.tl = F.shY - F.hipY
  return F
end

local function P(id, k, build)
  return { id = id, k = k, build = build }
end

local function headPart(F)
  return P("head", F.hrx * 0.24, function(g, n, F2, K)
    K.ellipsoid(g, n, 0, F2.hcy, 0, F2.hrx, F2.hry, F2.hrz)
  end)
end

local function neckPart(F)
  return P("neck", F.thw * 0.42, function(g, n, F2, K)
    K.capsule(g, n, 0, F2.headBot + F2.hry * 0.06, 0,
              0, F2.shY - F2.s * 0.30, 0, F2.hrx * 0.40, F2.thw * 0.46)
  end)
end

local function torsoPart(F, fit)
  local chest = fit.chest or 0.99
  local depth = fit.depth or 1.02
  return P("torso", F.thw * 0.17, function(g, n, F2, K)
    K.ellipsoid(g, n, 0, (F2.shY + F2.hipY) / 2, 0,
                F2.thw * chest, F2.tl / 2 * 1.26, F2.thz * depth)
  end)
end

local function collarPart(F, fit)
  local w = fit.collarW or 0.78
  local h = fit.collarH or 0.86
  local dy = fit.collarY or 0.10
  return P("collar", F.thw * 0.20, function(g, n, F2, K)
    K.ellipsoid(g, n, 0, F2.shY + F2.s * dy, -F2.thz * 0.06,
                F2.thw * w, F2.s * h, F2.thz * 0.86)
  end)
end

local STRIDE = {
  stand = { legZ = { 0, 0 }, lift = { 0, 0 }, armZ = { 0, 0 } },
  walk = { legZ = { 1.05, -0.78 }, lift = { 0.36, 0 },
           armZ = { -0.95, 1.30 } },
}

local function sides(pose)
  return STRIDE[pose] or STRIDE.stand
end

local function armPart(F, pose)
  local w = sides(pose)
  return P("arm", F.thw * 0.17, function(g, n, F2, K)
    for s = 1, 2 do
      local sx = (s == 1) and -1 or 1
      local dz = F2.armr * (0.3 + w.armZ[s])
      local dst = (s == 1) and g or K.tmp
      K.capsule(dst, n, sx * F2.armx, F2.armt, 0,
                sx * F2.armx * 0.96, F2.armb, dz,
                F2.armr, F2.armr * 0.84)
    end
    K.union(g, K.tmp, K.cells)
  end)
end

local function handPart(F, pose)
  local w = sides(pose)
  return P("hand", F.armr * 0.40, function(g, n, F2, K)
    local r = F2.armr * 0.92
    for s = 1, 2 do
      local sx = (s == 1) and -1 or 1
      local dz = F2.armr * (0.3 + w.armZ[s])
      local dst = (s == 1) and g or K.tmp
      K.ellipsoid(dst, n, sx * F2.armx * 0.96,
                  F2.armb - F2.armr * 0.35, dz, r, r, r)
    end
    K.union(g, K.tmp, K.cells)
  end)
end

local function legPart(F, pose)
  local w = sides(pose)
  return P("leg", F.legr * 0.85, function(g, n, F2, K)
    for s = 1, 2 do
      local sx = (s == 1) and -1 or 1
      local dst = (s == 1) and g or K.tmp
      K.capsule(dst, n, sx * F2.legx, F2.hipY + F2.legr * 0.3, 0,
                sx * F2.legx,
                F2.footY + F2.legr * (1.1 + w.lift[s]),
                F2.legr * w.legZ[s],
                F2.legr * 1.02, F2.legr * 0.86)
    end
    K.union(g, K.tmp, K.cells)
  end)
end

local function shoePart(F, fit, pose)
  local len = fit.shoeLen or 1.90
  local rr = fit.shoeR or 0.92
  local w = sides(pose)
  return P("shoe", F.legr * 0.55, function(g, n, F2, K)
    for s = 1, 2 do
      local sx = (s == 1) and -1 or 1
      local y = F2.footY + F2.legr * (0.52 + w.lift[s])
      local z0 = F2.legr * (w.legZ[s] - 0.25)
      local z1 = F2.legr * (w.legZ[s] + len)
      local dst = (s == 1) and g or K.tmp
      K.capsule(dst, n, sx * F2.legx, y, z0, sx * F2.legx, y, z1,
                F2.legr * rr, F2.legr * 0.76)
    end
    K.union(g, K.tmp, K.cells)
  end)
end

local function skirtPart(F, fit)
  local hem = F.Y(fit.hem or 14.20)
  local r0 = fit.skirtR0 or 0.96
  local r1 = fit.skirtR1 or 1.34
  local top = fit.skirtTop or 0.10
  return P("coat", F.thw * 0.18, function(g, n, F2, K)
    K.capsule(g, n, 0, F2.hipY + F2.tl * top, 0, 0, hem, 0,
              F2.thw * r0, F2.thw * r1)
    K.clipBelow(g, K.cells, n, hem)
  end)
end

local function coatPart(F, fit)
  local knee = F.Y(fit.hem or 12.55)
  return P("coat", F.thw * 0.18, function(g, n, F2, K)
    K.ellipsoid(g, n, 0, (F2.shY + F2.hipY) / 2 + F2.tl * 0.06, 0,
                F2.thw * 1.09, F2.tl / 2 * 1.34, F2.thz * 1.16)
    K.ellipsoid(K.tmp, n, 0, F2.hipY - (F2.hipY - knee) * 0.30, 0,
                F2.thw * 1.18, (F2.hipY - knee) * 0.88, F2.thz * 1.26)
    for i = 1, K.cells do
      g[i] = K.smax(g[i], K.tmp[i], F2.thw * 0.34)
    end
    K.clipBelow(g, K.cells, n, knee)
    K.capsule(K.tmp, n, 0, F2.shY - F2.s * 0.30, F2.thz * 1.10,
              0, F2.hipY + F2.tl * 0.10, F2.thz * 1.10,
              F2.thw * 0.46, F2.thw * 0.07)
    K.subtract(g, K.tmp, K.cells)
  end)
end

local function hairPart(F, h)
  return P("hair", F.hrx * 0.12, function(g, n, F2, K)
    local grow = h.grow or 1.082
    local lift = h.lift or 0.05
    local back = h.back or 0.04
    K.ellipsoid(g, n, 0, F2.hcy + F2.hry * lift, -F2.hrz * back,
                F2.hrx * grow, F2.hry * grow, F2.hrz * grow)
    local wx = h.winX or 0.56
    local wo = h.winOff or 0.27
    local wc = h.winCy or -0.34
    local wry = h.winRy or 0.82
    K.ellipsoid(K.tmp, n, -F2.hrx * wo, F2.hcy + F2.hry * wc, F2.hrz * 0.86,
                F2.hrx * wx, F2.hry * wry, F2.hrz * 1.04)
    K.subtract(g, K.tmp, K.cells)
    K.ellipsoid(K.tmp, n, F2.hrx * wo, F2.hcy + F2.hry * wc, F2.hrz * 0.86,
                F2.hrx * wx, F2.hry * wry, F2.hrz * 1.04)
    K.subtract(g, K.tmp, K.cells)

    local cut = h.cut or -0.58
    local yv = F2.hcy + F2.hry * cut
    local half = n / 2
    local i = 0
    for z = 0, n do
      local zback = -((z + 0.5 - half) + F2.hrz * 0.22)
      for y = 0, n do
        local d = (y + 0.5) - yv
        local keep = (d > zback) and d or zback
        for x = 0, n do
          i = i + 1
          if keep < g[i] then g[i] = keep end
        end
      end
    end

    local g2 = grow + 0.035
    local lshell = {}
    K.ellipsoid(K.tmp, n, 0, F2.hcy + F2.hry * lift, -F2.hrz * back,
                F2.hrx * g2, F2.hry * g2, F2.hrz * g2)
    for j = 1, K.cells do lshell[j] = K.tmp[j] end

    for _, lock in ipairs(h.locks or {}) do
      K.ellipsoid(K.tmp, n, lock[1] * F2.hrx, F2.hcy + lock[2] * F2.hry,
                  F2.hrz * 0.30, lock[3] * F2.hrx, 0.30 * F2.hry,
                  1.10 * F2.hrz)
      for j = 1, K.cells do
        local a = K.tmp[j]
        local b = lshell[j]
        local m = (a < b) and a or b
        g[j] = K.smax(g[j], m, F2.hrx * 0.05)
      end
    end

    for _, sp in ipairs(h.spikes or {}) do
      K.capsule(K.tmp, n, sp[1] * F2.hrx, F2.hcy + sp[2] * F2.hry,
                sp[3] * F2.hrz, sp[4] * F2.hrx, F2.hcy + sp[5] * F2.hry,
                sp[6] * F2.hrz, (h.spikeR or 0.30) * F2.hrx,
                (h.spikeT or 0.03) * F2.hrx)
      K.union(g, K.tmp, K.cells)
    end

    for _, st in ipairs(h.strands or {}) do
      K.capsule(K.tmp, n, st[1] * F2.hrx, F2.hcy + st[2] * F2.hry,
                st[3] * F2.hrz, st[4] * F2.hrx, F2.hcy + st[5] * F2.hry,
                st[6] * F2.hrz, st[7] * F2.hrx, st[8] * F2.hrx)
      K.union(g, K.tmp, K.cells)
    end

    if h.drape then
      local dw, dy, dz, dr = h.drape[1], h.drape[2], h.drape[3], h.drape[4]
      K.ellipsoid(K.tmp, n, 0, F2.hcy + F2.hry * dy, -F2.hrz * dz,
                  F2.hrx * dw, F2.hry * dr, F2.hrz * (dw * 0.92))
      local outer = {}
      for j = 1, K.cells do outer[j] = K.tmp[j] end
      K.ellipsoid(K.tmp, n, 0, F2.hcy + F2.hry * dy, -F2.hrz * dz,
                  F2.hrx * (dw - 0.16), F2.hry * (dr - 0.12),
                  F2.hrz * (dw * 0.92 - 0.16))
      K.subtract(outer, K.tmp, K.cells)
      K.clipFrontOf(outer, K.cells, n, F2.hrz * 0.30, -1)
      K.union(g, outer, K.cells)
    end
  end)
end

local function hatParts(F, t, out)
  if not t then return end
  local kind = t.kind
  if kind == "cap" or kind == "beanie" then
    local brim = t.brim or 3.85
    local grow = t.grow or 1.06
    out[#out + 1] = P("hat", F.hrx * 0.12, function(g, n, F2, K)
      K.ellipsoid(g, n, 0, F2.hcy + F2.hry * 0.10, 0,
                  F2.hrx * grow, F2.hry * 1.06 * grow / 1.05, F2.hrz * grow)
      K.clipBelow(g, K.cells, n, F2.Y(brim))
    end)
    if kind == "cap" then
      local fwd = t.fwd or 0.72
      out[#out + 1] = P("peak", F.hrx * 0.07, function(g, n, F2, K)
        local cy = F2.Y(brim)
        K.ellipsoid(g, n, 0, cy - F2.hry * 0.02, F2.hrz * fwd,
                    F2.hrx * 0.95, F2.hry * 0.080, F2.hrz * 0.82)
        K.clipFrontOf(g, K.cells, n, F2.hrz * (fwd > 0 and 0.50 or -0.50),
                      fwd > 0 and 1 or -1)
      end)
    end
  elseif kind == "nurse" then
    out[#out + 1] = P("hat", F.hrx * 0.12, function(g, n, F2, K)
      K.ellipsoid(g, n, 0, F2.hcy + F2.hry * 0.03, -F2.hrz * 0.02,
                  F2.hrx * 1.10, F2.hry * 1.10, F2.hrz * 1.10)
      K.clipBelow(g, K.cells, n, F2.hcy + F2.hry * 0.40)
      K.clipFrontOf(g, K.cells, n, F2.hrz * 0.62, -1)
    end)
  end
end

function RigSpecs.parts(spec, F, K, pose)
  local fit = spec.fit or {}
  local out = {}
  out[#out + 1] = torsoPart(F, fit)
  out[#out + 1] = armPart(F, pose)
  out[#out + 1] = handPart(F, pose)
  out[#out + 1] = legPart(F, pose)
  out[#out + 1] = shoePart(F, fit, pose)
  out[#out + 1] = neckPart(F)
  out[#out + 1] = collarPart(F, fit)
  local bottom = fit.bottom or "pants"
  if bottom == "skirt" or bottom == "dress" then
    out[#out + 1] = skirtPart(F, fit)
  elseif bottom == "coat" then
    out[#out + 1] = coatPart(F, fit)
  end
  out[#out + 1] = headPart(F)
  if spec.hair then out[#out + 1] = hairPart(F, spec.hair) end
  hatParts(F, spec.hat, out)
  return out
end

function RigSpecs.crisp(spec)
  return spec.crisp or { "head" }
end

local DEFAULT_EYE = {
  sep = 0.330, cy = -0.505, rw = 0.252, rh = 0.298,
  irisW = 0.182, irisH = 0.222, irisCy = -0.535,
  lidW = 0.268, lidH = 0.078, lidCy = -0.238,
  hiDx = 0.074, hiW = 0.072, hiH = 0.082, hiCy = -0.428,
}

local SCLERA = { 0.965, 0.965, 0.975 }
local WHITE = { 1.0, 1.0, 1.0 }

local function mix(c, o, t)
  if t <= 0 then return c end
  if t > 1 then t = 1 end
  return { c[1] + (o[1] - c[1]) * t,
           c[2] + (o[2] - c[2]) * t,
           c[3] + (o[3] - c[3]) * t }
end

local function ss(e0, e1, x)
  local d = e1 - e0
  if abs(d) < 1e-6 then d = (d >= 0) and 1e-6 or -1e-6 end
  local t = (x - e0) / d
  if t < 0 then t = 0 elseif t > 1 then t = 1 end
  return t * t * (3 - 2 * t)
end

function RigSpecs.faceTexel(spec, F, u, v, fz)
  return RigSpecs.colour(spec, F, "__face", u * F.hrx + F.n / 2,
                         v * F.hry + F.hcy, F.n / 2, 0, 0, fz)
end

function RigSpecs.colour(spec, F, part, gx, gy, gz, nx, ny, nz)
  local pal = spec.palette
  local fit = spec.fit or {}
  local base = pal[(part == "__face") and "head" or part]
               or pal.top or { 0.8, 0.8, 0.8 }
  local col = { base[1], base[2], base[3] }

  local n = F.n
  local x = gx - n / 2
  local y = gy
  local z = gz - n / 2
  local u = x / F.hrx
  local v = (y - F.hcy) / F.hry

  if part == "hair" or part == "hat" or part == "peak" then
    if pal.hairHi and part == "hair" then
      col = mix(col, pal.hairHi, ss(0.18, 0.88, ny) * 0.55)
    end
    if pal.hairSh and part == "hair" then
      col = mix(col, pal.hairSh, ss(0.05, -0.62, ny) * 0.55)
    end
    if pal.hatSh and part ~= "hair" then
      col = mix(col, pal.hatSh, ss(0.10, -0.55, ny) * 0.75)
    end
    return col
  end

  if part == "head" then
    return RigSpecs.faceTexel(spec, F, u, v, nz)
  end

  if part == "__face" then
    local e = spec.eye or DEFAULT_EYE
    local face = (nz > 0.10) and 1 or 0
    if face > 0 then
      local iris = e.iris or { 0.07, 0.075, 0.105 }
      for s = -1, 1, 2 do
        local du = u - s * (e.sep or DEFAULT_EYE.sep)
        local rw = e.rw or DEFAULT_EYE.rw
        local rh = e.rh or DEFAULT_EYE.rh
        local cy = e.cy or DEFAULT_EYE.cy
        local d = sqrt((du / rw) ^ 2 + ((v - cy) / rh) ^ 2)
        col = mix(col, SCLERA, ss(1.02, 0.90, d) * 0.98)
        local iw = e.irisW or rw * 0.72
        local ih = e.irisH or rh * 0.76
        local icy = e.irisCy or (cy - rh * 0.10)
        local di = sqrt((du / iw) ^ 2 + ((v - icy) / ih) ^ 2)
        col = mix(col, iris, ss(1.02, 0.86, di) * 0.98)
        local lw = e.lidW or rw * 1.08
        local lh = e.lidH or rh * 0.30
        local lcy = e.lidCy or (cy + rh * 0.82)
        local dl = sqrt((du / lw) ^ 2 + ((v - lcy) / lh) ^ 2)
        col = mix(col, iris, ss(1.05, 0.75, dl) * 0.85)
        if e.lash and e.lash > 0 then
          local dz2 = sqrt(((du - s * rw * 0.86) / (rw * 0.52)) ^ 2
                           + ((v - cy + rh * 0.42) / (rh * 0.34)) ^ 2)
          col = mix(col, iris, ss(1.05, 0.65, dz2) * e.lash)
        end
        local hw = e.hiW or rw * 0.28
        local hh = e.hiH or rh * 0.28
        local hcy = e.hiCy or (cy + rh * 0.26)
        local hdx = e.hiDx or rw * 0.29
        local dh = sqrt(((du + hdx) / hw) ^ 2 + ((v - hcy) / hh) ^ 2)
        col = mix(col, WHITE, ss(1.05, 0.55, dh) * 0.95)
        if e.brow then
          local db = sqrt((du / (rw * 1.16)) ^ 2
                          + ((v - (e.browCy or -0.14)) / (rh * 0.125)) ^ 2)
          col = mix(col, e.brow, ss(1.05, 0.70, db) * 0.78)
        end
      end
      local m = spec.mouth or {}
      local dm = sqrt((u / (m.w or 0.150)) ^ 2
                      + ((v - (m.cy or -0.762)) / (m.h or 0.046)) ^ 2)
      col = mix(col, pal.mouth or { 0.52, 0.23, 0.23 },
                ss(1.05, 0.70, dm) * (m.k or 0.46))
      if spec.shades then
        local gc = pal.glass or { 0.10, 0.10, 0.13 }
        for s = -1, 1, 2 do
          local d = sqrt(((u - s * 0.330) / 0.288) ^ 2
                         + ((v + 0.496) / 0.218) ^ 2)
          col = mix(col, gc, ss(1.02, 0.86, d) * 0.98)
        end
        col = mix(col, gc, ss(0.10, 0.02, abs(u))
                  * ss(0.14, 0.04, abs(v + 0.496)) * 0.95)
      end
      if spec.glasses then
        local gc = pal.glass or { 0.16, 0.16, 0.18 }
        for s = -1, 1, 2 do
          local d = sqrt(((u - s * 0.330) / 0.302) ^ 2
                         + ((v + 0.498) / 0.268) ^ 2)
          col = mix(col, gc, ss(1.02, 0.95, d) * ss(0.80, 0.90, d) * 0.95)
        end
        col = mix(col, gc, ss(0.09, 0.02, abs(u))
                  * ss(0.10, 0.03, abs(v + 0.498)) * 0.85)
      end
      if spec.beard then
        local d = sqrt((u / 0.50) ^ 2 + ((v + 0.812) / 0.242) ^ 2)
        col = mix(col, pal.beard or pal.hair, ss(1.05, 0.72, d) * 0.92)
      end
      if spec.stache then
        local d = sqrt((u / 0.30) ^ 2 + ((v + 0.688) / 0.062) ^ 2)
        col = mix(col, pal.beard or pal.hair, ss(1.05, 0.70, d) * 0.92)
      end
      if spec.blush then
        for s = -1, 1, 2 do
          local d = sqrt(((u - s * 0.560) / 0.190) ^ 2
                         + ((v + 0.640) / 0.130) ^ 2)
          col = mix(col, pal.blush or { 0.98, 0.62, 0.56 },
                    ss(1.0, 0.0, d) * spec.blush)
        end
      end
    end
    if pal.skinSh then
      col = mix(col, pal.skinSh, ss(-0.08, 0.10, v) * ss(0.0, 0.4, nz) * 0.45)
    end
    return col
  end

  if part == "torso" or part == "arm" then
    if pal.topHi then
      col = mix(col, pal.topHi, ss(0.55, 0.90, nz)
                * ss(0.28, 0.08, abs(x) / F.thw) * 0.50)
    end
    if part == "torso" then
      for _, b in ipairs(fit.bands or {}) do
        local lo, hi, key, k = b[1], b[2], b[3], b[4]
        local t = ss(F.hipY + F.tl * (hi + 0.13), F.hipY + F.tl * hi, y)
                  * ss(F.hipY + F.tl * (lo - 0.13), F.hipY + F.tl * lo, y)
        col = mix(col, pal[key] or pal.top, t * k)
      end
      if fit.emblem then
        local key, cy, r = fit.emblem[1], fit.emblem[2], fit.emblem[3]
        if nz > 0.35 then
          local d = sqrt((x / (F.thw * r)) ^ 2
                         + ((y - (F.hipY + F.tl * cy)) / (F.thw * r)) ^ 2)
          col = mix(col, pal[key] or pal.top, ss(1.02, 0.72, d) * 0.95)
        end
      end
      if fit.apron then
        local key, k = fit.apron[1], fit.apron[2]
        local t = ss(0.25, 0.68, nz) * ss(F.thw * 0.78, F.thw * 0.52, abs(x))
                  * ss(F.hipY + F.tl * 0.78, F.hipY + F.tl * 0.60, y)
        col = mix(col, pal[key] or pal.top, t * k)
      end
    end
    if part == "arm" and pal.cuff then
      col = mix(col, pal.cuff,
                ss(F.armb + F.armr * 0.75, F.armb + F.armr * 0.25, y) * 0.75)
    end
    return col
  end

  if part == "coat" and pal.coatSh then
    col = mix(col, pal.coatSh, ss(0.30, -0.30, ny) * 0.40)
    return col
  end

  if part == "leg" and pal.bottomSh then
    col = mix(col, pal.bottomSh,
              ss(F.hipY + F.legr * 1.20, F.hipY + F.legr * 0.50, y) * 0.60)
    return col
  end

  if part == "shoe" then
    col = mix(col, pal.soleC or { 0.925, 0.930, 0.940 },
              ss(F.footY + F.legr * 0.28, F.footY + F.legr * 0.02, y) * 0.92)
    return col
  end

  return col
end

local SPECS = V.require("RigCast")

function RigSpecs.lookup(image)
  if type(image) ~= "string" then return nil end
  local base = image:match("([^/\\]+)$") or image
  base = base:gsub("%.%w+$", ""):lower()
  local spec = SPECS[base]
  if spec and not spec.key then spec.key = base end
  return spec
end

RigSpecs.FRAMES = FRAMES

return RigSpecs
