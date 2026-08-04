local V = ...

local SKIN = { 0.980, 0.780, 0.620 }
local SKIN_SH = { 0.910, 0.680, 0.520 }
local TAN = { 0.912, 0.716, 0.552 }
local TAN_SH = { 0.822, 0.612, 0.452 }
local DARK = { 0.700, 0.500, 0.352 }
local DARK_SH = { 0.598, 0.410, 0.272 }
local SOLE = { 0.925, 0.930, 0.940 }
local WHITE = { 0.945, 0.950, 0.960 }

local M = {}

local EYE_BASE = {
  kid = { sep = 0.330, cy = -0.498, rw = 0.250, rh = 0.290 },
  teen = { sep = 0.322, cy = -0.492, rw = 0.252, rh = 0.288 },
  adult = { sep = 0.320, cy = -0.478, rw = 0.238, rh = 0.232 },
  bulk = { sep = 0.324, cy = -0.478, rw = 0.234, rh = 0.220 },
}

local function scaleEye(e, frame)
  e = e or {}
  local b = EYE_BASE[frame or "adult"]
  e.sep = e.sep or b.sep
  local rw0 = e.rw or b.rw
  local rh0 = e.rh or b.rh
  local cy0 = e.cy or b.cy
  local rw = rw0 * 0.786
  local rh = rh0 * 0.758
  local cy = cy0 + 0.49 * (rh0 - rh)
  e.irisW = (e.irisW or rw0 * 0.72) * 0.769
  e.irisH = (e.irisH or rh0 * 0.76) * 0.748
  e.lidW = (e.lidW or rw0 * 1.07) * 0.790
  e.lidH = (e.lidH or rh0 * 0.27) * 0.740
  e.hiDx = (e.hiDx or rw0 * 0.29) * 0.780
  e.hiW = (e.hiW or rw0 * 0.28) * 0.780
  e.hiH = (e.hiH or rh0 * 0.27) * 0.760
  e.rw, e.rh, e.cy = rw, rh, cy
  e.irisCy = cy - rh * 0.10
  e.lidCy = cy + rh * 0.92
  e.hiCy = cy + rh * 0.26
  e.iris = e.iris or { 0.104, 0.094, 0.100 }
  return e
end

local function finish(key, spec)
  local p = spec.palette
  spec.eye = scaleEye(spec.eye, spec.frame)
  spec.mouth = spec.mouth or { cy = -0.756, w = 0.140, h = 0.036, k = 0.40 }
  spec.hair = spec.hair or {}
  p.hair = p.hair or { 0.188, 0.140, 0.116 }
  p.hairHi = p.hairHi or { 0.312, 0.242, 0.196 }
  p.hairSh = p.hairSh or { 0.108, 0.076, 0.062 }
  p.skin = p.skin or SKIN
  p.mouth = p.mouth or { 0.520, 0.230, 0.230 }
  p.skinSh = p.skinSh or SKIN_SH
  p.head = p.skin
  p.hand = p.skin
  p.neck = p.skinSh
  p.torso = p.top
  p.arm = p.sleeve or p.top
  p.leg = p.bottom
  p.collar = p.collar or p.top
  p.coat = p.coat or p.bottom
  p.hat = p.hat or p.hair
  p.peak = p.peak or p.hat
  p.soleC = p.soleC or SOLE
  spec.key = key
  M[key] = spec
  return spec
end

finish("red", {
  frame = "kid",
  crisp = { "head", "hat", "peak" },
  hair = { winX = 0.72, winOff = 0.30, winCy = -0.26, winRy = 0.94,
           cut = -0.50, grow = 1.030 },
  hat = { kind = "cap", brim = 3.85, fwd = 0.72 },
  fit = { bottom = "pants", collarW = 0.82, collarH = 0.90, shoeLen = 1.85 },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.212, 0.152, 0.140 },
              hairHi = { 0.330, 0.256, 0.238 },
              hairSh = { 0.140, 0.096, 0.088 },
              hat = { 0.855, 0.180, 0.130 },
              hatSh = { 0.640, 0.110, 0.085 },
              top = { 0.145, 0.160, 0.245 },
              topHi = { 0.255, 0.280, 0.390 },
              sleeve = SKIN,
              collar = { 0.255, 0.280, 0.390 },
              bottom = { 0.255, 0.330, 0.510 },
              bottomSh = { 0.196, 0.256, 0.402 },
              shoe = { 0.760, 0.215, 0.170 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.330, cy = -0.505, rw = 0.252, rh = 0.298,
          iris = { 0.070, 0.075, 0.105 } },
  mouth = { cy = -0.775, w = 0.130, h = 0.044, k = 0.42 },
})

finish("blue", {
  frame = "kid",
  hair = { winX = 0.56, winOff = 0.27, winCy = -0.34, cut = -0.58,
           locks = { { -0.48, 0.33, 0.27 }, { -0.11, 0.41, 0.22 },
                     { 0.36, 0.30, 0.28 } },
           spikeR = 0.300, spikeT = 0.030,
           spikes = { { 0.00, 0.50, 0.30, 0.02, 1.62, -0.46 },
                      { -0.16, 0.52, 0.52, -0.30, 1.36, 0.34 },
                      { 0.16, 0.52, 0.52, 0.30, 1.36, 0.34 },
                      { -0.30, 0.46, 0.38, -0.58, 1.50, -0.28 },
                      { 0.30, 0.46, 0.38, 0.58, 1.50, -0.28 },
                      { -0.56, 0.36, 0.20, -1.06, 1.24, -0.62 },
                      { 0.56, 0.36, 0.20, 1.06, 1.24, -0.62 },
                      { -0.72, 0.18, -0.24, -1.34, 0.68, -0.96 },
                      { 0.72, 0.18, -0.24, 1.34, 0.68, -0.96 },
                      { -0.24, 0.22, -0.62, -0.34, 0.66, -1.66 },
                      { 0.24, 0.22, -0.62, 0.34, 0.66, -1.66 } } },
  fit = { bottom = "pants", collarW = 0.86, collarH = 0.34,
          bands = { { 0.42, 0.74, "accent", 0.90 } } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.352, 0.208, 0.112 },
              hairHi = { 0.492, 0.318, 0.182 },
              hairSh = { 0.238, 0.135, 0.072 },
              top = { 0.206, 0.214, 0.256 },
              topHi = { 0.268, 0.278, 0.330 },
              collar = { 0.612, 0.532, 0.768 },
              accent = { 0.452, 0.372, 0.618 },
              cuff = { 0.612, 0.532, 0.768 },
              bottom = { 0.792, 0.712, 0.532 },
              bottomSh = { 0.652, 0.575, 0.412 },
              shoe = { 0.246, 0.232, 0.352 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.328, cy = -0.492, rw = 0.244, rh = 0.262,
          irisW = 0.176, irisH = 0.196, irisCy = -0.520,
          lidW = 0.262, lidH = 0.090, lidCy = -0.268,
          hiDx = 0.070, hiW = 0.068, hiH = 0.076, hiCy = -0.418,
          iris = { 0.148, 0.092, 0.060 },
          brow = { 0.238, 0.135, 0.072 }, browCy = -0.196 },
  mouth = { cy = -0.775, w = 0.132, h = 0.044, k = 0.42 },
})

finish("oak", {
  frame = "adult",
  hair = { winX = 0.55, winOff = 0.28, winCy = -0.16, winRy = 0.88,
           cut = -0.52, grow = 1.088,
           strands = { { -0.90, 0.10, -0.12, -0.86, -0.42, 0.02, 0.17, 0.10 },
                       { 0.90, 0.10, -0.12, 0.86, -0.42, 0.02, 0.17, 0.10 } } },
  fit = { bottom = "coat", hem = 12.55, collarW = 0.70, collarH = 1.22,
          collarY = 0.52, shoeLen = 1.95, shoeR = 0.86 },
  palette = { skin = TAN, skinSh = TAN_SH,
              hair = { 0.742, 0.748, 0.760 },
              hairHi = { 0.882, 0.886, 0.895 },
              hairSh = { 0.552, 0.560, 0.578 },
              top = { 0.486, 0.152, 0.148 },
              topHi = { 0.598, 0.216, 0.202 },
              sleeve = { 0.902, 0.908, 0.922 },
              collar = { 0.902, 0.908, 0.922 },
              coat = { 0.902, 0.908, 0.922 },
              coatSh = { 0.742, 0.752, 0.780 },
              cuff = { 0.972, 0.975, 0.982 },
              bottom = { 0.578, 0.496, 0.382 },
              bottomSh = { 0.452, 0.378, 0.282 },
              shoe = { 0.302, 0.214, 0.152 },
              soleC = { 0.452, 0.378, 0.282 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.316, cy = -0.482, rw = 0.248, rh = 0.246,
          irisW = 0.178, irisH = 0.184, irisCy = -0.510,
          lidW = 0.264, lidH = 0.072, lidCy = -0.292,
          hiDx = 0.066, hiW = 0.062, hiH = 0.070, hiCy = -0.408,
          iris = { 0.132, 0.108, 0.086 },
          brow = { 0.742, 0.748, 0.760 }, browCy = -0.128 },
  mouth = { cy = -0.756, w = 0.176, h = 0.040, k = 0.46 },
})

finish("nurse", {
  frame = "teen",
  hair = { winX = 0.54, winOff = 0.26, winCy = -0.30, cut = -0.44,
           locks = { { -0.44, 0.30, 0.26 }, { 0.40, 0.28, 0.26 } },
           strands = { { -1.00, -0.06, -0.26, -1.06, -0.12, -0.32, 0.46, 0.44 },
                       { 1.00, -0.06, -0.26, 1.06, -0.12, -0.32, 0.46, 0.44 } } },
  hat = { kind = "nurse" },
  fit = { bottom = "dress", hem = 14.05, skirtR0 = 0.94, skirtR1 = 1.30,
          collarW = 0.80, shoeLen = 1.75, apron = { "accent", 0.55 } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.916, 0.462, 0.556 },
              hairHi = { 0.976, 0.606, 0.678 },
              hairSh = { 0.762, 0.322, 0.428 },
              hat = { 0.960, 0.962, 0.972 },
              hatSh = { 0.812, 0.818, 0.842 },
              top = { 0.948, 0.952, 0.966 },
              topHi = { 0.995, 0.996, 1.0 },
              collar = { 0.902, 0.912, 0.936 },
              coat = { 0.948, 0.952, 0.966 },
              coatSh = { 0.806, 0.816, 0.846 },
              accent = { 0.902, 0.322, 0.352 },
              cuff = { 0.902, 0.322, 0.352 },
              bottom = SKIN,
              shoe = { 0.918, 0.922, 0.936 },
              soleC = { 0.802, 0.808, 0.828 },
              blush = { 0.980, 0.620, 0.560 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.322, cy = -0.492, rw = 0.256, rh = 0.298,
          irisW = 0.190, irisH = 0.232, irisCy = -0.522,
          lidW = 0.268, lidH = 0.070, lidCy = -0.268,
          hiDx = 0.074, hiW = 0.074, hiH = 0.086, hiCy = -0.428,
          iris = { 0.328, 0.146, 0.192 }, lash = 0.85 },
  mouth = { cy = -0.768, w = 0.128, h = 0.042, k = 0.44 },
  blush = 0.30,
})

finish("clerk", {
  frame = "adult",
  hair = { winX = 0.54, winOff = 0.27, winCy = -0.24, cut = -0.50,
           locks = { { -0.42, 0.32, 0.26 }, { 0.02, 0.38, 0.22 },
                     { 0.44, 0.30, 0.26 } } },
  fit = { bottom = "pants", collarW = 0.80, collarH = 1.05,
          apron = { "apron", 0.90 },
          bands = { { 0.06, 0.24, "accent", 0.70 } } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.214, 0.152, 0.118 },
              hairHi = { 0.352, 0.258, 0.196 },
              hairSh = { 0.126, 0.086, 0.066 },
              top = { 0.180, 0.322, 0.492 },
              topHi = { 0.286, 0.442, 0.618 },
              collar = { 0.928, 0.936, 0.952 },
              apron = { 0.930, 0.938, 0.956 },
              accent = { 0.150, 0.256, 0.402 },
              cuff = { 0.928, 0.936, 0.952 },
              bottom = { 0.212, 0.232, 0.302 },
              bottomSh = { 0.148, 0.164, 0.222 },
              shoe = { 0.148, 0.142, 0.166 },
              soleC = { 0.108, 0.104, 0.126 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.320, cy = -0.478, rw = 0.240, rh = 0.248,
          irisW = 0.174, irisH = 0.186, irisCy = -0.506,
          lidW = 0.262, lidH = 0.074, lidCy = -0.286,
          hiDx = 0.068, hiW = 0.064, hiH = 0.072, hiCy = -0.412,
          iris = { 0.118, 0.096, 0.078 },
          brow = { 0.126, 0.086, 0.066 }, browCy = -0.132 },
  mouth = { cy = -0.760, w = 0.156, h = 0.040, k = 0.42 },
})

finish("youngster", {
  frame = "kid",
  hair = { winX = 0.55, winOff = 0.27, winCy = -0.30, cut = -0.48,
           grow = 1.040,
           locks = { { -0.42, 0.26, 0.25 }, { 0.40, 0.24, 0.25 } } },
  hat = { kind = "cap", brim = 3.95, grow = 1.115, fwd = -0.78 },
  fit = { bottom = "pants", shoeLen = 1.95,
          bands = { { 0.30, 0.46, "accent", 0.85 },
                    { 0.62, 0.78, "accent", 0.85 } } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.286, 0.196, 0.126 },
              hairHi = { 0.432, 0.318, 0.212 },
              hairSh = { 0.176, 0.114, 0.072 },
              hat = { 0.212, 0.392, 0.706 },
              hatSh = { 0.140, 0.268, 0.512 },
              top = { 0.938, 0.944, 0.958 },
              topHi = { 0.992, 0.994, 1.0 },
              collar = { 0.212, 0.392, 0.706 },
              accent = { 0.212, 0.392, 0.706 },
              cuff = { 0.212, 0.392, 0.706 },
              bottom = { 0.512, 0.402, 0.286 },
              bottomSh = { 0.412, 0.316, 0.216 },
              shoe = { 0.242, 0.246, 0.290 },
              blush = { 0.980, 0.620, 0.560 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.330, cy = -0.498, rw = 0.250, rh = 0.290,
          irisW = 0.184, irisH = 0.224, irisCy = -0.528,
          lidW = 0.266, lidH = 0.076, lidCy = -0.252,
          hiDx = 0.074, hiW = 0.072, hiH = 0.082, hiCy = -0.424,
          iris = { 0.104, 0.098, 0.126 } },
  mouth = { cy = -0.772, w = 0.142, h = 0.046, k = 0.44 },
  blush = 0.22,
})

finish("girl", {
  frame = "kid",
  hair = { winX = 0.56, winOff = 0.28, winCy = -0.30, cut = -0.40,
           locks = { { -0.46, 0.28, 0.27 }, { -0.04, 0.34, 0.23 },
                     { 0.42, 0.26, 0.27 } },
           strands = { { -0.94, 0.24, -0.22, -1.16, -1.28, -0.30, 0.28, 0.17 },
                       { 0.94, 0.24, -0.22, 1.16, -1.28, -0.30, 0.28, 0.17 } },
           drape = { 0.98, -0.20, 0.22, 0.98 } },
  fit = { bottom = "skirt", hem = 13.70, skirtR0 = 0.92, skirtR1 = 1.42,
          collarW = 0.76, shoeLen = 1.72,
          bands = { { 0.66, 0.86, "accent", 0.80 } } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.372, 0.226, 0.128 },
              hairHi = { 0.516, 0.338, 0.196 },
              hairSh = { 0.246, 0.140, 0.076 },
              top = { 0.936, 0.482, 0.552 },
              topHi = { 0.982, 0.610, 0.662 },
              collar = { 0.962, 0.966, 0.976 },
              accent = { 0.962, 0.966, 0.976 },
              cuff = { 0.962, 0.966, 0.976 },
              coat = { 0.936, 0.482, 0.552 },
              coatSh = { 0.788, 0.362, 0.436 },
              bottom = { 0.936, 0.482, 0.552 },
              shoe = { 0.882, 0.316, 0.352 },
              soleC = { 0.952, 0.955, 0.965 },
              blush = { 0.980, 0.620, 0.560 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.324, cy = -0.496, rw = 0.258, rh = 0.306,
          irisW = 0.192, irisH = 0.240, irisCy = -0.526,
          lidW = 0.270, lidH = 0.070, lidCy = -0.258,
          hiDx = 0.076, hiW = 0.076, hiH = 0.088, hiCy = -0.430,
          iris = { 0.208, 0.126, 0.086 }, lash = 0.90 },
  mouth = { cy = -0.772, w = 0.118, h = 0.042, k = 0.42 },
  blush = 0.32,
})

finish("gramps", {
  frame = "adult",
  hair = { winX = 0.60, winOff = 0.30, winCy = 0.10, winRy = 0.96,
           cut = -0.52, grow = 1.075,
           strands = { { -0.92, 0.16, -0.10, -0.86, -0.52, 0.02, 0.19, 0.12 },
                       { 0.92, 0.16, -0.10, 0.86, -0.52, 0.02, 0.19, 0.12 } } },
  fit = { bottom = "pants", collarW = 0.78, collarH = 0.92, chest = 1.03,
          depth = 1.06, shoeLen = 1.95,
          bands = { { 0.10, 0.30, "accent", 0.60 } } },
  palette = { skin = TAN, skinSh = TAN_SH,
              hair = { 0.868, 0.872, 0.882 },
              hairHi = { 0.948, 0.950, 0.958 },
              hairSh = { 0.678, 0.684, 0.702 },
              beard = { 0.888, 0.892, 0.902 },
              top = { 0.472, 0.362, 0.246 },
              topHi = { 0.598, 0.472, 0.336 },
              collar = { 0.906, 0.912, 0.928 },
              accent = { 0.362, 0.272, 0.180 },
              cuff = { 0.906, 0.912, 0.928 },
              bottom = { 0.348, 0.352, 0.392 },
              bottomSh = { 0.268, 0.272, 0.310 },
              shoe = { 0.256, 0.186, 0.136 },
              soleC = { 0.186, 0.136, 0.100 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.318, cy = -0.470, rw = 0.238, rh = 0.212,
          irisW = 0.170, irisH = 0.156, irisCy = -0.494,
          lidW = 0.260, lidH = 0.070, lidCy = -0.292,
          hiDx = 0.064, hiW = 0.060, hiH = 0.066, hiCy = -0.408,
          iris = { 0.130, 0.108, 0.090 },
          brow = { 0.792, 0.796, 0.810 }, browCy = -0.128 },
  mouth = { cy = -0.742, w = 0.130, h = 0.034, k = 0.30 },
  beard = true,
})

finish("rocket", {
  frame = "adult",
  hair = { winX = 0.55, winOff = 0.27, winCy = -0.28, cut = -0.50,
           locks = { { -0.44, 0.30, 0.25 }, { 0.02, 0.36, 0.21 },
                     { 0.42, 0.28, 0.25 } },
           spikeR = 0.26, spikeT = 0.05,
           spikes = { { -0.52, 0.44, 0.16, -0.90, 1.18, -0.34 },
                      { 0.52, 0.44, 0.16, 0.90, 1.18, -0.34 },
                      { 0.00, 0.54, -0.20, 0.02, 1.34, -0.72 } } },
  fit = { bottom = "pants", collarW = 0.82, collarH = 1.00, shoeLen = 2.00,
          shoeR = 0.98, emblem = { "accent", 0.62, 0.34 } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.148, 0.140, 0.162 },
              hairHi = { 0.268, 0.258, 0.298 },
              hairSh = { 0.088, 0.082, 0.100 },
              top = { 0.236, 0.232, 0.266 },
              topHi = { 0.252, 0.248, 0.286 },
              collar = { 0.108, 0.104, 0.126 },
              accent = { 0.882, 0.192, 0.196 },
              cuff = { 0.882, 0.192, 0.196 },
              bottom = { 0.236, 0.232, 0.266 },
              bottomSh = { 0.098, 0.096, 0.118 },
              shoe = { 0.086, 0.084, 0.104 },
              soleC = { 0.180, 0.176, 0.202 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.326, cy = -0.484, rw = 0.242, rh = 0.242,
          irisW = 0.174, irisH = 0.182, irisCy = -0.512,
          lidW = 0.264, lidH = 0.086, lidCy = -0.276,
          hiDx = 0.068, hiW = 0.064, hiH = 0.072, hiCy = -0.416,
          iris = { 0.096, 0.090, 0.116 },
          brow = { 0.088, 0.082, 0.100 }, browCy = -0.144 },
  mouth = { cy = -0.762, w = 0.148, h = 0.038, k = 0.40 },
})

finish("lance", {
  frame = "adult",
  hair = { winX = 0.55, winOff = 0.28, winCy = -0.26, cut = -0.48,
           locks = { { -0.46, 0.30, 0.26 }, { 0.00, 0.38, 0.22 },
                     { 0.44, 0.28, 0.26 } },
           spikeR = 0.29, spikeT = 0.035,
           spikes = { { 0.00, 0.56, 0.16, 0.02, 1.72, -0.38 },
                      { -0.34, 0.50, 0.26, -0.68, 1.58, -0.22 },
                      { 0.34, 0.50, 0.26, 0.68, 1.58, -0.22 },
                      { -0.64, 0.34, 0.04, -1.28, 1.22, -0.56 },
                      { 0.64, 0.34, 0.04, 1.28, 1.22, -0.56 },
                      { -0.24, 0.26, -0.58, -0.36, 0.80, -1.62 },
                      { 0.24, 0.26, -0.58, 0.36, 0.80, -1.62 } } },
  fit = { bottom = "coat", hem = 12.85, collarW = 0.86, collarH = 1.30,
          shoeLen = 2.05, shoeR = 0.98,
          bands = { { 0.10, 0.30, "accent", 0.55 } } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.838, 0.220, 0.132 },
              hairHi = { 0.948, 0.372, 0.238 },
              hairSh = { 0.652, 0.136, 0.086 },
              top = { 0.234, 0.230, 0.268 },
              topHi = { 0.268, 0.264, 0.312 },
              collar = { 0.256, 0.316, 0.552 },
              coat = { 0.246, 0.306, 0.548 },
              coatSh = { 0.162, 0.204, 0.386 },
              accent = { 0.782, 0.652, 0.268 },
              cuff = { 0.782, 0.652, 0.268 },
              bottom = { 0.234, 0.230, 0.268 },
              bottomSh = { 0.112, 0.110, 0.136 },
              shoe = { 0.096, 0.094, 0.116 },
              soleC = { 0.062, 0.060, 0.078 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.324, cy = -0.482, rw = 0.240, rh = 0.238,
          irisW = 0.172, irisH = 0.178, irisCy = -0.510,
          lidW = 0.262, lidH = 0.088, lidCy = -0.272,
          hiDx = 0.068, hiW = 0.064, hiH = 0.072, hiCy = -0.414,
          iris = { 0.328, 0.128, 0.096 },
          brow = { 0.652, 0.136, 0.086 }, browCy = -0.146 },
  mouth = { cy = -0.760, w = 0.144, h = 0.038, k = 0.40 },
})

finish("giovanni", {
  frame = "bulk",
  hair = { winX = 0.56, winOff = 0.28, winCy = -0.22, cut = -0.52,
           locks = { { -0.44, 0.34, 0.26 }, { 0.44, 0.32, 0.26 } },
           strands = { { -0.30, 0.62, 0.30, 0.46, 0.44, -0.50, 0.30, 0.22 } } },
  fit = { bottom = "pants", collarW = 0.84, collarH = 1.20, chest = 1.02,
          shoeLen = 2.05, shoeR = 0.98,
          bands = { { 0.08, 0.34, "accent", 0.45 } } },
  palette = { skin = TAN, skinSh = TAN_SH,
              hair = { 0.196, 0.148, 0.118 },
              hairHi = { 0.328, 0.256, 0.202 },
              hairSh = { 0.112, 0.082, 0.064 },
              top = { 0.286, 0.278, 0.320 },
              topHi = { 0.318, 0.310, 0.358 },
              collar = { 0.938, 0.942, 0.958 },
              accent = { 0.146, 0.140, 0.170 },
              cuff = { 0.938, 0.942, 0.958 },
              bottom = { 0.264, 0.258, 0.298 },
              bottomSh = { 0.136, 0.132, 0.160 },
              shoe = { 0.096, 0.092, 0.112 },
              soleC = { 0.062, 0.060, 0.076 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.326, cy = -0.478, rw = 0.236, rh = 0.216,
          irisW = 0.168, irisH = 0.158, irisCy = -0.502,
          lidW = 0.258, lidH = 0.094, lidCy = -0.280,
          hiDx = 0.066, hiW = 0.060, hiH = 0.066, hiCy = -0.410,
          iris = { 0.096, 0.086, 0.104 },
          brow = { 0.112, 0.082, 0.064 }, browCy = -0.150 },
  mouth = { cy = -0.756, w = 0.150, h = 0.034, k = 0.38 },
})

finish("scientist", {
  frame = "adult",
  hair = { winX = 0.54, winOff = 0.27, winCy = -0.26, cut = -0.50,
           locks = { { -0.44, 0.32, 0.26 }, { 0.02, 0.38, 0.22 },
                     { 0.44, 0.30, 0.26 } } },
  fit = { bottom = "coat", hem = 12.60, collarW = 0.80, collarH = 1.10,
          shoeLen = 1.95 },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.188, 0.140, 0.116 },
              hairHi = { 0.312, 0.242, 0.196 },
              hairSh = { 0.108, 0.076, 0.062 },
              top = { 0.286, 0.436, 0.612 },
              topHi = { 0.398, 0.552, 0.722 },
              sleeve = { 0.918, 0.924, 0.940 },
              collar = { 0.926, 0.932, 0.948 },
              coat = { 0.918, 0.924, 0.940 },
              coatSh = { 0.766, 0.774, 0.802 },
              cuff = { 0.958, 0.962, 0.972 },
              bottom = { 0.352, 0.360, 0.412 },
              bottomSh = { 0.268, 0.276, 0.322 },
              shoe = { 0.236, 0.232, 0.266 },
              soleC = { 0.108, 0.104, 0.126 },
              glass = { 0.196, 0.208, 0.242 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.322, cy = -0.480, rw = 0.238, rh = 0.238,
          irisW = 0.171, irisH = 0.181, irisCy = -0.504,
          lidW = 0.257, lidH = 0.071, lidCy = -0.285,
          hiDx = 0.069, hiW = 0.067, hiH = 0.067, hiCy = -0.418,
          iris = { 0.112, 0.096, 0.082 },
          brow = { 0.108, 0.076, 0.062 }, browCy = -0.130 },
  mouth = { cy = -0.758, w = 0.146, h = 0.038, k = 0.40 },
  glasses = true,
})

finish("beauty", {
  frame = "adult",
  hair = { winX = 0.54, winOff = 0.27, winCy = -0.32, cut = -0.34,
           locks = { { -0.46, 0.26, 0.27 }, { -0.02, 0.32, 0.22 },
                     { 0.44, 0.24, 0.27 } },
           drape = { 1.06, -0.44, 0.18, 1.18 } },
  fit = { bottom = "dress", hem = 13.90, skirtR0 = 0.92, skirtR1 = 1.36,
          collarW = 0.74, shoeLen = 1.70, chest = 0.94 },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.882, 0.702, 0.336 },
              hairHi = { 0.962, 0.842, 0.520 },
              hairSh = { 0.708, 0.526, 0.212 },
              top = { 0.912, 0.352, 0.462 },
              topHi = { 0.968, 0.492, 0.578 },
              collar = { 0.962, 0.966, 0.976 },
              coat = { 0.912, 0.352, 0.462 },
              coatSh = { 0.762, 0.242, 0.352 },
              accent = { 0.962, 0.966, 0.976 },
              bottom = SKIN,
              shoe = { 0.842, 0.256, 0.352 },
              soleC = { 0.702, 0.196, 0.276 },
              blush = { 0.980, 0.620, 0.560 },
              mouth = { 0.620, 0.200, 0.240 } },
  eye = { sep = 0.320, cy = -0.492, rw = 0.252, rh = 0.292,
          irisW = 0.181, irisH = 0.222, irisCy = -0.521,
          lidW = 0.272, lidH = 0.087, lidCy = -0.253,
          hiDx = 0.073, hiW = 0.070, hiH = 0.082, hiCy = -0.416,
          iris = { 0.156, 0.232, 0.372 }, lash = 0.52,
          brow = { 0.708, 0.526, 0.212 }, browCy = -0.130 },
  mouth = { cy = -0.768, w = 0.116, h = 0.044, k = 0.55 },
  blush = 0.34,
})

finish("hiker", {
  frame = "bulk",
  hair = { winX = 0.58, winOff = 0.28, winCy = -0.12, cut = -0.50,
           grow = 1.075,
           locks = { { -0.44, 0.28, 0.26 }, { 0.42, 0.26, 0.26 } } },
  fit = { bottom = "pants", collarW = 0.84, collarH = 1.00, chest = 1.06,
          depth = 1.08, shoeLen = 2.10, shoeR = 1.02,
          bands = { { 0.06, 0.26, "accent", 0.70 } } },
  palette = { skin = DARK, skinSh = DARK_SH,
              hair = { 0.168, 0.128, 0.098 },
              hairHi = { 0.286, 0.226, 0.176 },
              hairSh = { 0.096, 0.070, 0.054 },
              beard = { 0.150, 0.112, 0.086 },
              top = { 0.836, 0.612, 0.238 },
              topHi = { 0.928, 0.732, 0.372 },
              collar = { 0.652, 0.452, 0.156 },
              accent = { 0.462, 0.322, 0.148 },
              cuff = { 0.652, 0.452, 0.156 },
              bottom = { 0.296, 0.352, 0.286 },
              bottomSh = { 0.216, 0.262, 0.208 },
              shoe = { 0.262, 0.190, 0.136 },
              soleC = { 0.186, 0.136, 0.100 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.320, cy = -0.470, rw = 0.230, rh = 0.196,
          irisW = 0.166, irisH = 0.149, irisCy = -0.490,
          lidW = 0.248, lidH = 0.059, lidCy = -0.309,
          hiDx = 0.067, hiW = 0.064, hiH = 0.055, hiCy = -0.419,
          iris = { 0.108, 0.090, 0.076 },
          brow = { 0.096, 0.070, 0.054 }, browCy = -0.132 },
  mouth = { cy = -0.748, w = 0.140, h = 0.032, k = 0.28 },
  beard = true,
})

finish("sailor", {
  frame = "bulk",
  hair = { winX = 0.54, winOff = 0.27, winCy = -0.24, cut = -0.52,
           grow = 1.040,
           locks = { { -0.42, 0.26, 0.25 }, { 0.40, 0.24, 0.25 } } },
  hat = { kind = "beanie", brim = 2.80, grow = 1.115 },
  fit = { bottom = "pants", collarW = 0.86, collarH = 1.15, chest = 1.04,
          shoeLen = 2.05, shoeR = 1.00,
          bands = { { 0.34, 0.50, "accent", 0.90 },
                    { 0.66, 0.82, "accent", 0.90 } } },
  palette = { skin = TAN, skinSh = TAN_SH,
              hair = { 0.198, 0.152, 0.122 },
              hairHi = { 0.322, 0.258, 0.208 },
              hairSh = { 0.116, 0.086, 0.068 },
              hat = { 0.948, 0.952, 0.966 },
              hatSh = { 0.792, 0.798, 0.822 },
              top = { 0.942, 0.946, 0.960 },
              topHi = { 0.992, 0.994, 1.0 },
              collar = { 0.158, 0.256, 0.462 },
              accent = { 0.158, 0.256, 0.462 },
              cuff = { 0.158, 0.256, 0.462 },
              bottom = { 0.186, 0.230, 0.372 },
              bottomSh = { 0.132, 0.166, 0.278 },
              shoe = { 0.118, 0.112, 0.136 },
              soleC = { 0.080, 0.076, 0.096 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.322, cy = -0.474, rw = 0.232, rh = 0.206,
          irisW = 0.167, irisH = 0.157, irisCy = -0.495,
          lidW = 0.251, lidH = 0.062, lidCy = -0.305,
          hiDx = 0.067, hiW = 0.065, hiH = 0.058, hiCy = -0.420,
          iris = { 0.104, 0.092, 0.088 },
          brow = { 0.116, 0.086, 0.068 }, browCy = -0.136 },
  mouth = { cy = -0.752, w = 0.146, h = 0.034, k = 0.34 },
})

finish("biker", {
  frame = "bulk",
  hair = { winX = 0.55, winOff = 0.27, winCy = -0.26, cut = -0.50,
           locks = { { -0.44, 0.30, 0.25 }, { 0.42, 0.28, 0.25 } },
           spikeR = 0.27, spikeT = 0.04,
           spikes = { { 0.00, 0.54, 0.10, 0.02, 1.46, -0.44 },
                      { -0.40, 0.48, 0.18, -0.72, 1.32, -0.30 },
                      { 0.40, 0.48, 0.18, 0.72, 1.32, -0.30 },
                      { -0.68, 0.30, -0.08, -1.22, 0.92, -0.62 },
                      { 0.68, 0.30, -0.08, 1.22, 0.92, -0.62 } } },
  fit = { bottom = "pants", collarW = 0.86, collarH = 1.10, chest = 1.05,
          shoeLen = 2.10, shoeR = 1.02,
          bands = { { 0.08, 0.30, "accent", 0.55 } } },
  palette = { skin = TAN, skinSh = TAN_SH,
              hair = { 0.152, 0.144, 0.166 },
              hairHi = { 0.272, 0.262, 0.302 },
              hairSh = { 0.090, 0.084, 0.102 },
              top = { 0.250, 0.244, 0.280 },
              topHi = { 0.286, 0.278, 0.322 },
              collar = { 0.118, 0.114, 0.136 },
              accent = { 0.622, 0.472, 0.146 },
              cuff = { 0.622, 0.472, 0.146 },
              bottom = { 0.214, 0.218, 0.264 },
              bottomSh = { 0.102, 0.106, 0.142 },
              shoe = { 0.092, 0.088, 0.108 },
              soleC = { 0.060, 0.058, 0.072 },
              glass = { 0.086, 0.086, 0.106 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.326, cy = -0.484, rw = 0.238, rh = 0.234,
          irisW = 0.171, irisH = 0.178, irisCy = -0.507,
          lidW = 0.257, lidH = 0.070, lidCy = -0.292,
          hiDx = 0.069, hiW = 0.067, hiH = 0.066, hiCy = -0.423,
          iris = { 0.098, 0.092, 0.112 } },
  mouth = { cy = -0.756, w = 0.152, h = 0.032, k = 0.36 },
  shades = true,
})

finish("gentleman", {
  frame = "adult",
  hair = { winX = 0.60, winOff = 0.30, winCy = 0.14, winRy = 0.98,
           cut = -0.52, grow = 1.070,
           strands = { { -0.92, 0.14, -0.10, -0.86, -0.48, 0.02, 0.18, 0.11 },
                       { 0.92, 0.14, -0.10, 0.86, -0.48, 0.02, 0.18, 0.11 } } },
  fit = { bottom = "pants", collarW = 0.80, collarH = 1.18, chest = 1.04,
          depth = 1.06, shoeLen = 2.00,
          bands = { { 0.06, 0.28, "accent", 0.50 } } },
  palette = { skin = SKIN, skinSh = SKIN_SH,
              hair = { 0.828, 0.832, 0.846 },
              hairHi = { 0.928, 0.930, 0.940 },
              hairSh = { 0.638, 0.644, 0.664 },
              beard = { 0.846, 0.850, 0.862 },
              top = { 0.238, 0.228, 0.286 },
              topHi = { 0.348, 0.338, 0.408 },
              collar = { 0.942, 0.946, 0.960 },
              accent = { 0.592, 0.176, 0.196 },
              cuff = { 0.942, 0.946, 0.960 },
              bottom = { 0.226, 0.218, 0.272 },
              bottomSh = { 0.162, 0.156, 0.202 },
              shoe = { 0.108, 0.102, 0.124 },
              soleC = { 0.070, 0.066, 0.082 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.318, cy = -0.470, rw = 0.232, rh = 0.198,
          irisW = 0.167, irisH = 0.150, irisCy = -0.490,
          lidW = 0.251, lidH = 0.059, lidCy = -0.308,
          hiDx = 0.067, hiW = 0.065, hiH = 0.055, hiCy = -0.419,
          iris = { 0.116, 0.100, 0.086 },
          brow = { 0.782, 0.786, 0.800 }, browCy = -0.126 },
  mouth = { cy = -0.752, w = 0.128, h = 0.030, k = 0.26 },
  stache = true,
})

finish("koga", {
  frame = "adult",
  hair = { winX = 0.54, winOff = 0.27, winCy = -0.24, cut = -0.46,
           locks = { { -0.44, 0.30, 0.26 }, { 0.02, 0.36, 0.22 },
                     { 0.44, 0.28, 0.26 } },
           drape = { 0.96, -0.10, 0.24, 0.92 } },
  fit = { bottom = "coat", hem = 13.10, collarW = 0.86, collarH = 1.25,
          chest = 1.02, shoeLen = 1.95,
          bands = { { 0.10, 0.32, "accent", 0.60 } } },
  palette = { skin = TAN, skinSh = TAN_SH,
              hair = { 0.142, 0.136, 0.158 },
              hairHi = { 0.252, 0.244, 0.286 },
              hairSh = { 0.086, 0.080, 0.098 },
              top = { 0.230, 0.224, 0.260 },
              topHi = { 0.258, 0.250, 0.298 },
              collar = { 0.402, 0.256, 0.552 },
              coat = { 0.392, 0.248, 0.542 },
              coatSh = { 0.268, 0.158, 0.386 },
              accent = { 0.782, 0.732, 0.256 },
              cuff = { 0.782, 0.732, 0.256 },
              bottom = { 0.230, 0.224, 0.260 },
              bottomSh = { 0.104, 0.100, 0.126 },
              shoe = { 0.096, 0.092, 0.114 },
              soleC = { 0.062, 0.060, 0.074 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.324, cy = -0.478, rw = 0.234, rh = 0.204,
          irisW = 0.168, irisH = 0.155, irisCy = -0.498,
          lidW = 0.253, lidH = 0.061, lidCy = -0.311,
          hiDx = 0.068, hiW = 0.066, hiH = 0.057, hiCy = -0.425,
          iris = { 0.108, 0.096, 0.116 },
          brow = { 0.086, 0.080, 0.098 }, browCy = -0.142 },
  mouth = { cy = -0.754, w = 0.140, h = 0.032, k = 0.34 },
})

finish("agatha", {
  frame = "adult",
  hair = { winX = 0.52, winOff = 0.26, winCy = -0.30, cut = -0.36,
           locks = { { -0.46, 0.24, 0.27 }, { -0.02, 0.30, 0.22 },
                     { 0.44, 0.22, 0.27 } },
           drape = { 1.02, -0.28, 0.20, 1.06 } },
  fit = { bottom = "dress", hem = 14.30, skirtR0 = 0.94, skirtR1 = 1.30,
          collarW = 0.76, shoeLen = 1.70, chest = 0.96 },
  palette = { skin = { 0.902, 0.760, 0.652 },
              skinSh = { 0.802, 0.640, 0.532 },
              hair = { 0.882, 0.886, 0.898 },
              hairHi = { 0.952, 0.954, 0.962 },
              hairSh = { 0.692, 0.698, 0.716 },
              top = { 0.452, 0.286, 0.552 },
              topHi = { 0.572, 0.396, 0.672 },
              collar = { 0.312, 0.186, 0.402 },
              coat = { 0.442, 0.278, 0.542 },
              coatSh = { 0.302, 0.172, 0.386 },
              accent = { 0.312, 0.186, 0.402 },
              bottom = { 0.352, 0.216, 0.442 },
              shoe = { 0.192, 0.152, 0.242 },
              soleC = { 0.132, 0.104, 0.172 },
              mouth = { 0.520, 0.230, 0.230 } },
  eye = { sep = 0.318, cy = -0.472, rw = 0.230, rh = 0.190,
          irisW = 0.166, irisH = 0.144, irisCy = -0.491,
          lidW = 0.248, lidH = 0.057, lidCy = -0.316,
          hiDx = 0.067, hiW = 0.064, hiH = 0.053, hiCy = -0.423,
          iris = { 0.132, 0.108, 0.148 },
          brow = { 0.792, 0.796, 0.812 }, browCy = -0.126, lash = 0.55 },
  mouth = { cy = -0.748, w = 0.116, h = 0.030, k = 0.30 },
})

local function W(x, o, c, cut)
  return { winX = x, winOff = o, winCy = c, cut = cut or -0.50,
           locks = { { -0.44, 0.30, 0.26 }, { 0.02, 0.36, 0.22 },
                     { 0.42, 0.28, 0.26 } } }
end

local function LONG(x, o, c, cut, dw, dy, dz, dr)
  local h = W(x, o, c, cut)
  h.drape = { dw, dy, dz, dr }
  return h
end

local function BALD(x, o, c)
  return { winX = x, winOff = o, winCy = c, winRy = 0.96, cut = -0.52,
           grow = 1.072,
           strands = { { -0.92, 0.15, -0.10, -0.86, -0.50, 0.02, 0.18, 0.11 },
                       { 0.92, 0.15, -0.10, 0.86, -0.50, 0.02, 0.18, 0.11 } } }
end

local BROWN = { 0.286, 0.196, 0.126 }
local BROWN_HI = { 0.432, 0.318, 0.212 }
local BROWN_SH = { 0.176, 0.114, 0.072 }
local BLACKH = { 0.168, 0.160, 0.180 }
local BLACKH_HI = { 0.288, 0.278, 0.316 }
local BLACKH_SH = { 0.098, 0.092, 0.110 }
local GREY = { 0.848, 0.852, 0.864 }
local GREY_HI = { 0.938, 0.940, 0.950 }
local GREY_SH = { 0.658, 0.664, 0.682 }

local function pal(t)
  t.hairHi = t.hairHi or (t.hair == BROWN and BROWN_HI)
                      or (t.hair == BLACKH and BLACKH_HI)
                      or (t.hair == GREY and GREY_HI)
  t.hairSh = t.hairSh or (t.hair == BROWN and BROWN_SH)
                      or (t.hair == BLACKH and BLACKH_SH)
                      or (t.hair == GREY and GREY_SH)
  return t
end

finish("balding_guy", {
  frame = "adult", hair = BALD(0.60, 0.30, 0.16),
  fit = { collarW = 0.78, collarH = 0.95, chest = 1.04, depth = 1.06 },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = GREY,
                  top = { 0.322, 0.482, 0.406 },
                  topHi = { 0.436, 0.598, 0.520 },
                  collar = { 0.918, 0.924, 0.938 },
                  bottom = { 0.352, 0.322, 0.286 },
                  bottomSh = { 0.268, 0.244, 0.212 },
                  shoe = { 0.212, 0.176, 0.146 } }),
  eye = { brow = GREY_SH, browCy = -0.128 },
})

finish("bike_shop_clerk", {
  frame = "adult", hair = W(0.54, 0.27, -0.26),
  fit = { collarW = 0.80, collarH = 1.08,
          bands = { { 0.34, 0.62, "accent", 0.80 } } },
  palette = pal({ skin = SKIN, hair = BROWN,
                  top = { 0.892, 0.462, 0.196 },
                  topHi = { 0.962, 0.598, 0.312 },
                  collar = { 0.928, 0.932, 0.944 },
                  accent = { 0.928, 0.932, 0.944 },
                  bottom = { 0.226, 0.256, 0.352 },
                  bottomSh = { 0.162, 0.186, 0.262 },
                  shoe = { 0.148, 0.142, 0.166 } }),
})

finish("bruno", {
  frame = "bulk", hair = W(0.55, 0.27, -0.24),
  fit = { chest = 1.02, depth = 1.04, collarW = 0.86, collarH = 0.60,
          shoeLen = 2.05, shoeR = 1.00 },
  palette = pal({ skin = DARK, skinSh = DARK_SH, hair = BLACKH,
                  top = DARK, topHi = { 0.792, 0.586, 0.428 },
                  sleeve = DARK, collar = DARK,
                  bottom = { 0.936, 0.940, 0.952 },
                  bottomSh = { 0.792, 0.798, 0.818 },
                  shoe = { 0.402, 0.286, 0.196 } }),
  eye = { brow = BLACKH_SH, browCy = -0.146 },
})

finish("captain", {
  frame = "adult", hair = W(0.54, 0.27, -0.24),
  hat = { kind = "beanie", brim = 2.90, grow = 1.115 },
  fit = { collarW = 0.86, collarH = 1.18, chest = 1.04,
          bands = { { 0.08, 0.30, "accent", 0.70 } } },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = GREY,
                  hat = { 0.936, 0.940, 0.954 },
                  hatSh = { 0.176, 0.212, 0.336 },
                  top = { 0.936, 0.940, 0.954 },
                  topHi = { 0.988, 0.990, 0.996 },
                  collar = { 0.176, 0.212, 0.336 },
                  accent = { 0.176, 0.212, 0.336 },
                  cuff = { 0.176, 0.212, 0.336 },
                  bottom = { 0.176, 0.212, 0.336 },
                  bottomSh = { 0.126, 0.152, 0.246 },
                  shoe = { 0.108, 0.102, 0.126 } }),
  eye = { brow = GREY_SH, browCy = -0.130 },
})

finish("channeler", {
  frame = "adult", hair = LONG(0.52, 0.26, -0.30, -0.34, 1.04, -0.34, 0.20, 1.12),
  fit = { bottom = "dress", hem = 14.30, skirtR0 = 0.94, skirtR1 = 1.28,
          collarW = 0.76, shoeLen = 1.70, chest = 0.94 },
  palette = pal({ skin = { 0.958, 0.842, 0.786 },
                  skinSh = { 0.872, 0.732, 0.678 }, hair = BLACKH,
                  top = { 0.876, 0.312, 0.376 },
                  topHi = { 0.948, 0.436, 0.492 },
                  collar = { 0.936, 0.940, 0.952 },
                  coat = { 0.876, 0.312, 0.376 },
                  coatSh = { 0.716, 0.216, 0.286 },
                  bottom = { 0.876, 0.312, 0.376 },
                  shoe = { 0.286, 0.196, 0.246 } }),
  eye = { lash = 0.70, iris = { 0.216, 0.126, 0.156 } },
})

finish("cook", {
  frame = "bulk", hair = W(0.55, 0.27, -0.22),
  hat = { kind = "beanie", brim = 2.20, grow = 1.15 },
  fit = { chest = 1.08, depth = 1.08, collarW = 0.86, collarH = 1.10 },
  palette = pal({ skin = SKIN, hair = BLACKH,
                  hat = { 0.958, 0.962, 0.972 },
                  hatSh = { 0.812, 0.818, 0.836 },
                  top = { 0.948, 0.952, 0.964 },
                  topHi = { 0.996, 0.997, 1.0 },
                  collar = { 0.896, 0.902, 0.918 },
                  bottom = { 0.352, 0.356, 0.396 },
                  bottomSh = { 0.268, 0.272, 0.308 },
                  shoe = { 0.148, 0.142, 0.166 } }),
})

finish("cooltrainer_f", {
  frame = "adult", hair = LONG(0.54, 0.27, -0.30, -0.36, 1.02, -0.32, 0.20, 1.08),
  fit = { bottom = "skirt", hem = 13.90, skirtR0 = 0.92, skirtR1 = 1.34,
          collarW = 0.76, shoeLen = 1.75, chest = 0.95,
          bands = { { 0.62, 0.84, "accent", 0.80 } } },
  palette = pal({ skin = SKIN, hair = BROWN,
                  top = { 0.226, 0.486, 0.632 },
                  topHi = { 0.348, 0.612, 0.748 },
                  collar = { 0.946, 0.950, 0.960 },
                  accent = { 0.946, 0.950, 0.960 },
                  coat = { 0.196, 0.226, 0.316 },
                  coatSh = { 0.136, 0.158, 0.226 },
                  bottom = SKIN,
                  shoe = { 0.836, 0.256, 0.286 } }),
  eye = { lash = 0.85, iris = { 0.156, 0.212, 0.312 } },
})

finish("daisy", {
  frame = "adult", hair = LONG(0.54, 0.27, -0.30, -0.34, 1.04, -0.36, 0.20, 1.12),
  fit = { bottom = "dress", hem = 14.10, skirtR0 = 0.92, skirtR1 = 1.32,
          collarW = 0.76, shoeLen = 1.72, chest = 0.94 },
  palette = pal({ skin = SKIN, hair = { 0.836, 0.652, 0.312 },
                  hairHi = { 0.942, 0.802, 0.482 },
                  hairSh = { 0.662, 0.482, 0.196 },
                  top = { 0.936, 0.482, 0.552 },
                  topHi = { 0.982, 0.610, 0.662 },
                  collar = { 0.962, 0.966, 0.976 },
                  coat = { 0.936, 0.482, 0.552 },
                  coatSh = { 0.788, 0.362, 0.436 },
                  bottom = SKIN,
                  shoe = { 0.882, 0.316, 0.352 } }),
  eye = { lash = 0.85, iris = { 0.196, 0.132, 0.092 } },
  blush = 0.28,
})

finish("fisher", {
  frame = "bulk", hair = W(0.55, 0.27, -0.22),
  fit = { chest = 1.06, depth = 1.06, collarW = 0.84, collarH = 1.00,
          shoeLen = 2.10, shoeR = 1.02,
          bands = { { 0.36, 0.52, "accent", 0.85 },
                    { 0.66, 0.82, "accent", 0.85 } } },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = BROWN,
                  beard = BROWN_SH,
                  top = { 0.936, 0.940, 0.952 },
                  topHi = { 0.990, 0.992, 0.998 },
                  collar = { 0.196, 0.256, 0.412 },
                  accent = { 0.196, 0.256, 0.412 },
                  bottom = { 0.286, 0.322, 0.406 },
                  bottomSh = { 0.206, 0.236, 0.302 },
                  shoe = { 0.226, 0.186, 0.146 } }),
  beard = true,
})

finish("fishing_guru", {
  frame = "bulk", hair = BALD(0.60, 0.30, 0.18),
  fit = { chest = 1.08, depth = 1.10, collarW = 0.84, collarH = 0.95 },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = GREY,
                  beard = { 0.878, 0.882, 0.892 },
                  top = { 0.836, 0.436, 0.216 },
                  topHi = { 0.928, 0.572, 0.336 },
                  collar = { 0.918, 0.922, 0.936 },
                  bottom = { 0.302, 0.336, 0.286 },
                  bottomSh = { 0.226, 0.252, 0.212 },
                  shoe = { 0.226, 0.176, 0.136 } }),
  eye = { brow = GREY_SH, browCy = -0.128 },
  beard = true,
})

finish("gambler", {
  frame = "adult", hair = W(0.54, 0.27, -0.24),
  fit = { collarW = 0.82, collarH = 1.20, chest = 1.03,
          bands = { { 0.06, 0.28, "accent", 0.55 } } },
  palette = pal({ skin = SKIN, hair = BLACKH,
                  top = { 0.246, 0.212, 0.302 },
                  topHi = { 0.356, 0.316, 0.426 },
                  collar = { 0.946, 0.950, 0.962 },
                  accent = { 0.812, 0.652, 0.216 },
                  cuff = { 0.946, 0.950, 0.962 },
                  bottom = { 0.226, 0.196, 0.276 },
                  bottomSh = { 0.162, 0.140, 0.202 },
                  shoe = { 0.116, 0.106, 0.132 } }),
  eye = { brow = BLACKH_SH, browCy = -0.142 },
})

finish("gameboy_kid", {
  frame = "kid", hair = W(0.55, 0.27, -0.30, -0.48),
  fit = { shoeLen = 1.90,
          bands = { { 0.40, 0.70, "accent", 0.80 } } },
  palette = pal({ skin = SKIN, hair = BROWN,
                  top = { 0.892, 0.352, 0.286 },
                  topHi = { 0.958, 0.482, 0.396 },
                  collar = { 0.946, 0.950, 0.960 },
                  accent = { 0.946, 0.950, 0.960 },
                  bottom = { 0.256, 0.316, 0.462 },
                  bottomSh = { 0.186, 0.232, 0.352 },
                  shoe = { 0.236, 0.240, 0.286 } }),
  blush = 0.24,
})

finish("granny", {
  frame = "adult", hair = W(0.56, 0.28, -0.18, -0.42),
  fit = { bottom = "dress", hem = 14.40, skirtR0 = 0.94, skirtR1 = 1.26,
          collarW = 0.76, shoeLen = 1.70, chest = 0.98 },
  palette = pal({ skin = { 0.912, 0.782, 0.686 },
                  skinSh = { 0.816, 0.668, 0.566 }, hair = GREY,
                  top = { 0.616, 0.482, 0.586 },
                  topHi = { 0.736, 0.606, 0.702 },
                  collar = { 0.936, 0.940, 0.952 },
                  coat = { 0.606, 0.472, 0.576 },
                  coatSh = { 0.462, 0.346, 0.436 },
                  bottom = { 0.512, 0.396, 0.486 },
                  shoe = { 0.246, 0.196, 0.236 } }),
  eye = { brow = GREY_SH, browCy = -0.126, lash = 0.45 },
})

finish("guard", {
  frame = "bulk", hair = W(0.54, 0.27, -0.22),
  hat = { kind = "cap", brim = 3.60, grow = 1.10, fwd = 0.74 },
  fit = { chest = 1.05, collarW = 0.86, collarH = 1.15, shoeLen = 2.05,
          shoeR = 0.98, bands = { { 0.08, 0.32, "accent", 0.60 } } },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = BLACKH,
                  hat = { 0.176, 0.226, 0.336 },
                  hatSh = { 0.116, 0.152, 0.236 },
                  top = { 0.196, 0.246, 0.362 },
                  topHi = { 0.296, 0.356, 0.482 },
                  collar = { 0.916, 0.922, 0.936 },
                  accent = { 0.812, 0.702, 0.286 },
                  cuff = { 0.812, 0.702, 0.286 },
                  bottom = { 0.176, 0.222, 0.326 },
                  bottomSh = { 0.126, 0.160, 0.240 },
                  shoe = { 0.096, 0.092, 0.112 } }),
  eye = { brow = BLACKH_SH, browCy = -0.144 },
})

finish("gym_guide", {
  frame = "adult", hair = BALD(0.60, 0.30, 0.14),
  fit = { collarW = 0.80, collarH = 1.00, chest = 1.04,
          bands = { { 0.32, 0.64, "accent", 0.70 } } },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = GREY,
                  top = { 0.286, 0.596, 0.362 },
                  topHi = { 0.412, 0.712, 0.482 },
                  collar = { 0.926, 0.930, 0.942 },
                  accent = { 0.926, 0.930, 0.942 },
                  bottom = { 0.352, 0.322, 0.276 },
                  bottomSh = { 0.266, 0.242, 0.206 },
                  shoe = { 0.216, 0.176, 0.140 } }),
  eye = { brow = GREY_SH, browCy = -0.128 },
})

finish("little_boy", {
  frame = "kid", hair = W(0.55, 0.27, -0.30, -0.46),
  fit = { shoeLen = 1.85,
          bands = { { 0.44, 0.72, "accent", 0.75 } } },
  palette = pal({ skin = SKIN, hair = BROWN,
                  top = { 0.396, 0.686, 0.856 },
                  topHi = { 0.522, 0.786, 0.928 },
                  collar = { 0.946, 0.950, 0.960 },
                  accent = { 0.946, 0.950, 0.960 },
                  bottom = { 0.836, 0.616, 0.286 },
                  bottomSh = { 0.686, 0.492, 0.216 },
                  shoe = { 0.236, 0.240, 0.286 } }),
  blush = 0.30,
})

finish("lorelei", {
  frame = "adult", hair = LONG(0.52, 0.26, -0.30, -0.32, 1.06, -0.40, 0.20, 1.16),
  fit = { bottom = "dress", hem = 14.05, skirtR0 = 0.92, skirtR1 = 1.34,
          collarW = 0.76, shoeLen = 1.72, chest = 0.94 },
  palette = pal({ skin = { 0.972, 0.856, 0.792 },
                  skinSh = { 0.882, 0.746, 0.686 },
                  hair = { 0.286, 0.226, 0.352 },
                  hairHi = { 0.412, 0.342, 0.492 },
                  hairSh = { 0.186, 0.142, 0.236 },
                  top = { 0.876, 0.286, 0.336 },
                  topHi = { 0.948, 0.412, 0.452 },
                  collar = { 0.946, 0.950, 0.962 },
                  coat = { 0.866, 0.276, 0.326 },
                  coatSh = { 0.712, 0.186, 0.246 },
                  bottom = { 0.826, 0.246, 0.296 },
                  shoe = { 0.256, 0.216, 0.312 },
                  glass = { 0.216, 0.226, 0.266 } }),
  eye = { lash = 0.80, iris = { 0.176, 0.246, 0.362 } },
  glasses = true,
})

finish("middle_aged_man", {
  frame = "adult", hair = W(0.56, 0.28, -0.16, -0.50),
  fit = { collarW = 0.80, collarH = 1.05, chest = 1.04, depth = 1.05 },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = BROWN,
                  top = { 0.386, 0.436, 0.556 },
                  topHi = { 0.502, 0.552, 0.662 },
                  collar = { 0.926, 0.930, 0.942 },
                  bottom = { 0.336, 0.312, 0.286 },
                  bottomSh = { 0.256, 0.236, 0.216 },
                  shoe = { 0.196, 0.166, 0.136 } }),
  eye = { brow = BROWN_SH, browCy = -0.132 },
})

finish("middle_aged_woman", {
  frame = "adult", hair = W(0.54, 0.27, -0.24, -0.40),
  fit = { bottom = "dress", hem = 14.20, skirtR0 = 0.94, skirtR1 = 1.28,
          collarW = 0.76, shoeLen = 1.70, chest = 0.96 },
  palette = pal({ skin = SKIN, hair = BROWN,
                  top = { 0.786, 0.526, 0.616 },
                  topHi = { 0.882, 0.646, 0.716 },
                  collar = { 0.946, 0.950, 0.960 },
                  coat = { 0.776, 0.516, 0.606 },
                  coatSh = { 0.626, 0.386, 0.472 },
                  bottom = { 0.676, 0.436, 0.516 },
                  shoe = { 0.256, 0.206, 0.216 } }),
  eye = { lash = 0.60 },
})

finish("mom", {
  frame = "adult", hair = LONG(0.54, 0.27, -0.28, -0.38, 1.00, -0.28, 0.20, 1.04),
  fit = { bottom = "dress", hem = 14.15, skirtR0 = 0.94, skirtR1 = 1.30,
          collarW = 0.76, shoeLen = 1.70, chest = 0.95 },
  palette = pal({ skin = SKIN, hair = BROWN,
                  top = { 0.876, 0.386, 0.396 },
                  topHi = { 0.946, 0.512, 0.506 },
                  collar = { 0.952, 0.956, 0.966 },
                  coat = { 0.866, 0.376, 0.386 },
                  coatSh = { 0.712, 0.276, 0.296 },
                  bottom = SKIN,
                  shoe = { 0.286, 0.206, 0.176 } }),
  eye = { lash = 0.75, iris = { 0.196, 0.132, 0.092 } },
  blush = 0.24,
})

finish("mr_fuji", {
  frame = "adult", hair = BALD(0.60, 0.30, 0.20),
  fit = { bottom = "coat", hem = 13.40, collarW = 0.84, collarH = 1.24,
          chest = 1.02, shoeLen = 1.90 },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = GREY,
                  beard = { 0.888, 0.892, 0.902 },
                  top = { 0.586, 0.256, 0.216 },
                  topHi = { 0.702, 0.362, 0.312 },
                  sleeve = { 0.826, 0.782, 0.686 },
                  cuff = { 0.702, 0.656, 0.562 },
                  collar = { 0.836, 0.792, 0.696 },
                  coat = { 0.826, 0.782, 0.686 },
                  coatSh = { 0.672, 0.626, 0.532 },
                  bottom = { 0.586, 0.552, 0.482 },
                  bottomSh = { 0.462, 0.432, 0.372 },
                  shoe = { 0.256, 0.216, 0.176 } }),
  eye = { brow = GREY_SH, browCy = -0.126 },
  beard = true,
})

finish("rocker", {
  frame = "adult",
  hair = { winX = 0.55, winOff = 0.27, winCy = -0.26, cut = -0.50,
           locks = { { -0.44, 0.30, 0.25 }, { 0.42, 0.28, 0.25 } },
           spikeR = 0.24, spikeT = 0.035,
           spikes = { { 0.00, 0.52, 0.20, 0.02, 1.62, -0.20 },
                      { -0.26, 0.50, 0.10, -0.36, 1.52, -0.36 },
                      { 0.26, 0.50, 0.10, 0.36, 1.52, -0.36 },
                      { -0.10, 0.44, -0.42, -0.14, 1.36, -0.86 } } },
  fit = { collarW = 0.84, collarH = 1.05, chest = 1.02,
          bands = { { 0.08, 0.30, "accent", 0.60 } } },
  palette = pal({ skin = SKIN, hair = { 0.856, 0.286, 0.216 },
                  hairHi = { 0.952, 0.436, 0.336 },
                  hairSh = { 0.666, 0.176, 0.126 },
                  top = { 0.186, 0.176, 0.206 },
                  topHi = { 0.296, 0.286, 0.336 },
                  collar = { 0.126, 0.120, 0.146 },
                  accent = { 0.826, 0.716, 0.246 },
                  cuff = { 0.826, 0.716, 0.246 },
                  bottom = { 0.156, 0.150, 0.186 },
                  bottomSh = { 0.106, 0.102, 0.132 },
                  shoe = { 0.096, 0.092, 0.114 } }),
})

finish("safari_zone_worker", {
  frame = "adult", hair = W(0.54, 0.27, -0.24),
  hat = { kind = "cap", brim = 3.60, grow = 1.10, fwd = 0.76 },
  fit = { collarW = 0.84, collarH = 1.05, chest = 1.03, shoeLen = 2.00,
          bands = { { 0.08, 0.30, "accent", 0.60 } } },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = BROWN,
                  hat = { 0.556, 0.596, 0.376 },
                  hatSh = { 0.406, 0.442, 0.256 },
                  top = { 0.596, 0.636, 0.406 },
                  topHi = { 0.712, 0.746, 0.516 },
                  collar = { 0.476, 0.512, 0.316 },
                  accent = { 0.396, 0.336, 0.216 },
                  bottom = { 0.516, 0.552, 0.346 },
                  bottomSh = { 0.396, 0.426, 0.262 },
                  shoe = { 0.256, 0.206, 0.146 } }),
})

finish("silph_president", {
  frame = "adult", hair = BALD(0.60, 0.30, 0.16),
  fit = { collarW = 0.80, collarH = 1.20, chest = 1.04, depth = 1.05,
          bands = { { 0.06, 0.28, "accent", 0.50 } } },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = GREY,
                  beard = { 0.878, 0.882, 0.892 },
                  top = { 0.226, 0.222, 0.256 },
                  topHi = { 0.336, 0.330, 0.376 },
                  collar = { 0.946, 0.950, 0.962 },
                  accent = { 0.586, 0.176, 0.196 },
                  cuff = { 0.946, 0.950, 0.962 },
                  bottom = { 0.212, 0.208, 0.242 },
                  bottomSh = { 0.152, 0.148, 0.178 },
                  shoe = { 0.106, 0.102, 0.122 } }),
  eye = { brow = GREY_SH, browCy = -0.126 },
  beard = true,
})

finish("silph_worker_f", {
  frame = "adult", hair = LONG(0.54, 0.27, -0.28, -0.38, 1.00, -0.26, 0.20, 1.04),
  fit = { bottom = "coat", hem = 12.70, collarW = 0.78, collarH = 1.10,
          chest = 0.96, shoeLen = 1.78 },
  palette = pal({ skin = SKIN, hair = BROWN,
                  top = { 0.286, 0.436, 0.612 },
                  topHi = { 0.398, 0.552, 0.722 },
                  sleeve = { 0.918, 0.924, 0.940 },
                  collar = { 0.926, 0.932, 0.948 },
                  coat = { 0.918, 0.924, 0.940 },
                  coatSh = { 0.766, 0.774, 0.802 },
                  cuff = { 0.958, 0.962, 0.972 },
                  bottom = { 0.322, 0.330, 0.382 },
                  bottomSh = { 0.246, 0.252, 0.296 },
                  shoe = { 0.236, 0.232, 0.266 } }),
  eye = { lash = 0.75 },
})

finish("super_nerd", {
  frame = "adult", hair = W(0.54, 0.27, -0.22, -0.46),
  fit = { collarW = 0.80, collarH = 1.10, chest = 1.02,
          bands = { { 0.06, 0.26, "accent", 0.60 } } },
  palette = pal({ skin = { 0.968, 0.836, 0.732 },
                  skinSh = { 0.876, 0.716, 0.616 }, hair = BLACKH,
                  top = { 0.926, 0.930, 0.944 },
                  topHi = { 0.986, 0.988, 0.994 },
                  collar = { 0.876, 0.882, 0.902 },
                  accent = { 0.556, 0.226, 0.256 },
                  bottom = { 0.396, 0.372, 0.322 },
                  bottomSh = { 0.302, 0.282, 0.242 },
                  shoe = { 0.196, 0.176, 0.146 },
                  glass = { 0.206, 0.216, 0.246 } }),
  eye = { brow = BLACKH_SH, browCy = -0.140 },
  glasses = true,
})

finish("swimmer", {
  frame = "adult", hair = W(0.54, 0.27, -0.26),
  fit = { collarW = 0.72, collarH = 0.50, chest = 0.98, shoeLen = 1.55,
          shoeR = 0.72 },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = BROWN,
                  top = TAN, topHi = { 0.968, 0.796, 0.632 },
                  sleeve = TAN, collar = TAN,
                  bottom = { 0.196, 0.436, 0.716 },
                  bottomSh = { 0.146, 0.326, 0.552 },
                  shoe = TAN, soleC = TAN_SH }),
})

finish("waiter", {
  frame = "adult", hair = W(0.54, 0.27, -0.24),
  fit = { collarW = 0.80, collarH = 1.22, chest = 1.02,
          bands = { { 0.06, 0.30, "accent", 0.55 } } },
  palette = pal({ skin = SKIN, hair = BLACKH,
                  top = { 0.264, 0.260, 0.298 },
                  topHi = { 0.302, 0.296, 0.342 },
                  collar = { 0.952, 0.956, 0.966 },
                  accent = { 0.586, 0.166, 0.186 },
                  cuff = { 0.952, 0.956, 0.966 },
                  bottom = { 0.240, 0.236, 0.274 },
                  bottomSh = { 0.126, 0.122, 0.146 },
                  shoe = { 0.096, 0.092, 0.112 } }),
  eye = { brow = BLACKH_SH, browCy = -0.140 },
})

finish("warden", {
  frame = "adult", hair = BALD(0.60, 0.30, 0.18),
  fit = { collarW = 0.80, collarH = 1.00, chest = 1.04, depth = 1.06 },
  palette = pal({ skin = TAN, skinSh = TAN_SH, hair = GREY,
                  beard = { 0.882, 0.886, 0.896 },
                  top = { 0.626, 0.522, 0.376 },
                  topHi = { 0.742, 0.636, 0.482 },
                  collar = { 0.912, 0.916, 0.928 },
                  bottom = { 0.396, 0.362, 0.302 },
                  bottomSh = { 0.302, 0.276, 0.226 },
                  shoe = { 0.226, 0.186, 0.146 } }),
  eye = { brow = GREY_SH, browCy = -0.128 },
  beard = true,
})

M.brunette_girl = M.girl
M.little_girl = M.girl
M.cooltrainer_m = M.blue
M.silph_worker_m = M.scientist
M.link_receptionist = M.nurse

M.unused_scientist = M.scientist
M.unused_guard = M.guard
M.gambler_asleep = M.gambler
M.unused_gameboy_kid = M.gameboy_kid

local PROPS = V.require("RigProps")
for k, v in pairs(PROPS) do M[k] = v end
M.unused_old_amber = M.old_amber

return M
