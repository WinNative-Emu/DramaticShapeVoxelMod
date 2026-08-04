package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")

local ROOT = os.getenv("DS_MOD_PATH") or "mods/DramaticShapeVoxelMod"
local V = { path = ROOT }

local function chunkFor(rel)
  local f = assert(io.open(ROOT .. "/" .. rel, "rb"), rel .. " is missing")
  local src = f:read("*a")
  f:close()
  return assert(load(src, "@" .. ROOT .. "/" .. rel))
end

local modules = {}
function V.require(name)
  if modules[name] == nil then
    modules[name] = chunkFor("lib/" .. name .. ".lua")(V)
  end
  return modules[name]
end

local SHEET_W, SHEET_H = 16, 96

local sheets = {}

local function newSheet()
  local px = {}
  return {
    px = px,
    getDimensions = function() return SHEET_W, SHEET_H end,
    getPixel = function(self, x, y)
      if px[y * SHEET_W + x] then return 0.2, 0.2, 0.2, 1 end
      return 1, 1, 1, 1
    end,
  }
end

local function fill(sheet, frame, x0, y0, x1, y1)
  for y = y0, y1 do
    for x = x0, x1 do
      sheet.px[(frame * 16 + y) * SHEET_W + x] = true
    end
  end
end

package.loaded["src.render.Assets"] = {
  imageData = function(path)
    local s = sheets[path]
    if not s then error("no sheet for " .. tostring(path)) end
    return s
  end,
  register = function() end,
  image = function() return nil end,
  loader = nil,
}

local ActorHull = V.require("ActorHull")

local box = newSheet()
fill(box, 0, 4, 4, 11, 11)
fill(box, 1, 4, 4, 11, 11)
fill(box, 2, 4, 4, 11, 11)
sheets["box.png"] = box

local def = { image = "box.png", frames = 6, walker = true }
local verts, indices, quads, voxels = ActorHull.geometry(def, "stand")

T.check(verts ~= nil, "a solid box carves")
T.eq(voxels, 8 * 8 * 8, "the hull is exactly the 8x8x8 box the views describe")
T.eq(quads, 6 * 8 * 8, "a closed box exposes exactly its six faces")
T.eq(#verts, quads * 4, "four vertices per quad")
T.eq(#indices, quads * 6, "six indices per quad")

local slab = newSheet()
fill(slab, 0, 4, 4, 11, 11)
fill(slab, 1, 4, 4, 11, 11)
fill(slab, 2, 6, 4, 9, 11)
sheets["slab.png"] = slab

local _, _, _, slabVoxels =
  ActorHull.geometry({ image = "slab.png", frames = 6 }, "stand")
T.eq(slabVoxels, 8 * 8 * 4,
  "a four-column side view carves the box four voxels deep")

local wing = newSheet()
fill(wing, 0, 4, 4, 7, 11)
fill(wing, 1, 4, 4, 7, 11)
fill(wing, 2, 4, 4, 11, 11)
sheets["wing.png"] = wing

local _, _, _, wingVoxels =
  ActorHull.geometry({ image = "wing.png", frames = 6 }, "stand")
T.eq(wingVoxels, 8 * 8 * 8,
  "the back frame mirrors into the outline and widens it rather than eroding it")

local blank = newSheet()
sheets["blank.png"] = blank
T.check(ActorHull.geometry({ image = "blank.png", frames = 6 }, "stand") == nil,
  "a sheet with no ink in it carves nothing")

local speck = newSheet()
fill(speck, 0, 4, 4, 11, 11)
fill(speck, 1, 4, 4, 11, 11)
fill(speck, 2, 4, 4, 11, 11)
fill(speck, 0, 0, 0, 0, 0)
fill(speck, 1, 0, 0, 0, 0)
fill(speck, 2, 0, 0, 0, 0)
sheets["speck.png"] = speck

local _, _, _, speckVoxels =
  ActorHull.geometry({ image = "speck.png", frames = 6 }, "stand")
T.eq(speckVoxels, 8 * 8 * 8,
  "a loose corner pixel is not part of the body and is dropped")

T.eq(ActorHull.poseFor(def, 0), "stand", "frame 0 is a standing pose")
T.eq(ActorHull.poseFor(def, 2), "stand", "frame 2 is standing left")
T.eq(ActorHull.poseFor(def, 3), "walk", "frame 3 is a walking pose")
T.eq(ActorHull.poseFor(def, 5), "walk", "frame 5 is walking left")
T.eq(ActorHull.poseFor({ image = "box.png", frames = 3 }, 2), "stand",
  "a three-frame sheet has no walk pose to reach")

local ball = newSheet()
fill(ball, 0, 4, 4, 11, 11)
sheets["ball.png"] = ball

local _, _, _, ballVoxels =
  ActorHull.geometry({ image = "ball.png", frames = 1 }, "stand")
T.eq(ballVoxels, 8 * 8 * 8,
  "with no side view the front's own width profile carves the depth")

local N = ActorHull.SIZE
local vOk, uvOk = true, true
for _, v in ipairs(verts) do
  if v[1] < 0 or v[1] > N or v[2] < 0 or v[2] > N or v[3] < 0 or v[3] > N then
    vOk = false
  end
  if v[4] < 0 or v[4] > 1 or v[5] < 0 or v[5] > 1 then uvOk = false end
end
T.check(vOk, "no vertex escapes the 16x16x16 model box")
T.check(uvOk, "every texture coordinate lands inside the sheet")

T.finish("DRAMATIC_SHAPE actor hulls")
