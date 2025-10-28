extends TileMapLayer

@export var crate_scene: PackedScene
var crate_tile_coords = Vector2i(0, 1)

func _ready() -> void:
	# Find every tile in the tilemap that is set to CRATE and replace it with a real crate!
	for cell in get_used_cells():
		var atlas_coords = get_cell_atlas_coords(cell)
		

		# Check if this tile matches your crate tile
		if atlas_coords == crate_tile_coords:
			var crate = crate_scene.instantiate()
			crate.position = map_to_local(cell)
			get_parent().add_child.call_deferred(crate)
			set_cell(cell, -1)  # remove the tile from the TileMap
