# How to build a level

This is a summarized version of the [tutorial](https://docs.godotengine.org/en/3.1/tutorials/2d/using_tilemaps.html#introduction) on tile sets.

## Placing tiles

Levels are built using a [`TileMap`](https://docs.godotengine.org/en/3.1/classes/class_tilemap.html), which contains a set of tiles. To place a tile:

1. Select the `Walls` node in the `Prototype` scene.
2. Select a tile from the `TileMap` pane on the right of the editor.
3. Left click to place a tile on the grid.
    a. Or press `a`/`s` to rotate.
    b. Or right click to remove.

Note: the grid is smaller than the size of the tile, so your tiles may overlap.

## Editing the `TileSet`

The current tile set uses a [free tile sheet](https://kenney.nl/assets/abstract-platformer). You can add or change the tiles by clicking on the `TileSet` resource in the property inspector for the `Walls` node. 