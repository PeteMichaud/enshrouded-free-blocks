# Free Blocks

Unlocked building blocks and road materials are free to craft. 

Craft as many wood, stone, roof, or any other building blocks, and as much road, as your base needs without gathering the materials. You still have to unlock each recipe the normal way. 

Weapons, armor, food, furniture, and upgrades still cost what they always did.

## Requirements

- [EML (Enshrouded Mod Loader)](https://www.nexusmods.com/enshrouded/mods/135)

Tested on game version: 1287369 (Steam build 26430625), with EML v0.2.0

## Install

1. [Install EML](https://brabb3l.github.io/kfc-parser/eml/usage.html). 
  * In short: download EML from its [Nexus page](https://www.nexusmods.com/enshrouded/mods/135), copy `dbghelp.dll` into the Enshrouded game folder, and create a `mods` folder next to it.
2. Download `free-blocks-<version>.zip` from the [latest release](https://github.com/PeteMichaud/enshrouded-free-blocks/releases/latest) and unzip it into `mods`, so this folder sits at `<Enshrouded>/mods/free-blocks/`, with `mod.json` directly inside it.
3. Start the game.

To uninstall, delete the `free-blocks` folder. Uninstalling is safe, it will simply restore the previous recipe costs.

## Checking that it worked

Set `enable_console` to `true` in `eml.json` in the game folder. On launch the console prints one line per recipe it changed, then a summary:

```
[free-blocks] 74 blocks and 7 roads found, 81 recipes made free
```

If it reports that nothing was changed, a game update has changed the recipe data and the mod needs updating.

## License

MIT. See `LICENSE`.
