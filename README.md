# Dramatic Shape Voxel Mod

A mod for the [Pokémon Gen 1 Recompilation
Project](https://github.com/bryanthaboi/pokemon-gen1-recomp-project).

The overworld as a 3D diorama. Terrain is extruded into real geometry,
occlusion comes from a depth buffer rather than a y-sort, characters stand
as leaning sprite slabs -- or, on the TRUE 3D rung, as real carved bodies
that turn to face where they are walking -- a shadow map throws real cast shadows across
whatever they land on, and an optional tilt-shift pass sells the
miniature-model look.

And battles fought on that world rather than on a white field. When
something picks a fight the map's NPCs are culled, the engine's own wipe
plays over the empty map, and the battle draws over the nearest patch of
clear ground — shot over the shoulder, the player's mon low and left and
the enemy high and right, with a slow parallax drift behind them and a
depth-of-field pass that keeps both of them sharp.

Purely presentational. Nothing here reaches collision, movement, triggers
or scripts — it changes what the world *looks* like and nothing about what
it *is*. The battle arena is where the **camera** goes, not where anybody
goes: no cell, facing, flag or warp is written, so the player is standing
exactly where the fight found them when it ends.

## Controls

Every key is free-roam only, and each one is also a row on the OPTIONS
menu.

| control | does |
| --- | --- |
| `3`, or the **VOXEL** options row | OFF → FULL → 3D → 15 → 35 → 50 → 75 → OFF (camera pitch) |
| `5`, or the **V-GRID** options row | OFF / ON — a one-pixel wireframe on every voxel |
| `6`, or the **T-SHIFT** options row | OFF → 1 → 2 → 3 → OFF (miniature blur) |
| `7`, or the **V-CURVE** options row | OFF → 1 → 2 → 3 — bend the world over the horizon |
| `8`, or the **3D-BTL** options row | ON / OFF — fight on the map instead of on a white field |
| the **BACK SPRITES** options row | OFF / ON — keep your own Pokémon on the battle menu, seen from behind in its classic slot, instead of standing it on the map; the foe is still out there. Only on the menu while **3D-BTL** is on, because it decides nothing without it |
| the **DAYTIME** options row | SYNC / DAY / NIGHT / DUSK / DAWN / CYCLE — what time it is outdoors, on the diorama *and* on the flat 2D world; held at SYNC (and off the menu) while VOXEL is FULL |

**3D-BTL** is on by default and is independent of **VOXEL**: battles draw
on the world whether or not the free-roam camera is pitched over.

Two of the engine's own rows are taken away while this mod is installed:
**TILT**, which is the flat fake of what this mode does for real, and **GBC
FX**, a full-screen present pass over the top of the diorama. Both are held at
off rather than merely hidden — a row that is not there cannot switch off a
value an older save arrived with. Uninstall and both come back, at whatever
they were last set to.

Everything the battle screen draws as a box — the two HUD blocks, the text
box and the menus over it — sits on frosted glass rather than on the white
field it used to have behind it: the world underneath, blurred and laid back
down translucent, with the ink flipping white where the ground it lands on is
dark. Nothing the engine draws inside a box moves; only the paper is gone.

## TRUE 3D

The **3D** rung is the FULL preset with one thing changed: actors are
geometry rather than cards.

A character is a **visual hull** carved from the three orthographic views its
own sprite sheet already holds -- front, back and side, which is what Gen 1's
six drawn poses amount to (`data/sprites/facings.asm`). The carve runs on the
device, from the sheet the engine already handed over, and the result lives in
memory; the mod ships no models and writes nothing.

The visible difference is that a hull can **turn**. A card cannot, which is why
a figure in FULL faces south at every tilt and right-facing is a mirror of
left. On this rung a character yaws to its heading, so one hull per sheet and
pose serves all four facings.

Battling Pokemon stand as solids too, built differently and deliberately so: a
pic gives only two views and both are frontal, so there is nothing to carve
depth from. Each row of the pic is revolved instead -- the row's span gives a
centre and a half-width and every column runs that circle's chord -- the same
construction the tree canopies already use. It is a rounded body rather than a
sculpt, which is the most two frontal views honestly support.

FULL and 3D are two rungs of one ladder, so exactly one of them is ever on.
