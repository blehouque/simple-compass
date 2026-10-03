# Simple Compass

A lightweight World of Warcraft compass addon.

## Features

- No dependencies
- Dynamically displays facing direction
- Movable frame
- Position saved automatically
- Lock / unlock support
- Low CPU usage

## Customization

Edit `Config.lua` to change the compass dimensions, visible angle, marker spacing,
update interval, default position, or cardinal labels. The implementation is split
by responsibility: persistence (`Database.lua`), direction math (`Direction.lua`),
rendering (`CompassView.lua`), slash commands (`Commands.lua`), and lifecycle/update
coordination (`Core.lua`).

## Commands

/sc lock
/sc unlock
/sc reset$