extends Node2D
class_name IceGenerator

## Preloaded IceTile scene
@export var ice_tile_scene: PackedScene = preload("res://ice_tile.tscn")

@export var tile_size: float = 96.0
@export var spawn_rows_ahead: int = 12
@export var spawn_cols_wide: int = 15
@export var despawn_distance_behind: float = 500.0

@export_range(0.0, 1.0) var thin_ice_chance: float = 0.30 ## 30% chance of pre-cracked ice
@export_range(0.0, 1.0) var water_gap_chance: float = 0.10 ## 10% chance of open water hole

var active_tiles: Dictionary = {} # Maps Vector2i(col, row) -> IceTile
var player_train: Node2D
var last_player_row: int = -9999


func _ready() -> void:
	# Find locomotive in scene tree
	player_train = get_node_or_null("../Locomotive") as Node2D
	_generate_initial_grid()


func _process(_delta: float) -> void:
	if not player_train:
		player_train = get_node_or_null("../Locomotive") as Node2D
		return

	var current_row: int = int(floor(player_train.global_position.y / tile_size))
	var current_col: int = int(floor(player_train.global_position.x / tile_size))

	# Update ice grid around player train position
	_update_grid_around(current_col, current_row)


## Generate initial safe grid around starting position
func _generate_initial_grid() -> void:
	var start_col: int = 0
	var start_row: int = 0
	
	if player_train:
		start_row = int(floor(player_train.global_position.y / tile_size))
		start_col = int(floor(player_train.global_position.x / tile_size))

	for row_offset in range(-3, spawn_rows_ahead):
		for col_offset in range(-int(spawn_cols_wide / 2.0), int(spawn_cols_wide / 2.0) + 1):
			var grid_pos: Vector2i = Vector2i(start_col + col_offset, start_row + row_offset)
			
			# Keep starting tiles solid ice
			var is_start_zone: bool = abs(row_offset) <= 2
			_spawn_tile_at(grid_pos, is_start_zone)


## Update active grid rows ahead and clean up old tiles behind
func _update_grid_around(center_col: int, center_row: int) -> void:
	# Spawn new rows ahead
	var min_row: int = center_row - 3
	var max_row: int = center_row + spawn_rows_ahead
	var min_col: int = center_col - int(spawn_cols_wide / 2.0)
	var max_col: int = center_col + int(spawn_cols_wide / 2.0)

	for r in range(min_row, max_row + 1):
		for c in range(min_col, max_col + 1):
			var grid_pos: Vector2i = Vector2i(c, r)
			if not active_tiles.has(grid_pos):
				_spawn_tile_at(grid_pos, false)

	# Clean up distant tiles behind to maintain performance (despawn)
	var keys_to_remove: Array[Vector2i] = []
	var player_y: float = player_train.global_position.y

	for grid_pos in active_tiles.keys():
		var tile: IceTile = active_tiles[grid_pos]
		if is_instance_valid(tile):
			# If tile is far behind train, despawn it
			if abs(tile.global_position.y - player_y) > despawn_distance_behind + 300.0 or \
			   abs(tile.global_position.x - player_train.global_position.x) > (spawn_cols_wide * tile_size):
				tile.queue_free()
				keys_to_remove.append(grid_pos)

	for k in keys_to_remove:
		active_tiles.erase(k)


## Spawn individual tile with randomized thin ice / water gap properties
func _spawn_tile_at(grid_pos: Vector2i, is_safe_start: bool) -> void:
	if active_tiles.has(grid_pos):
		return

	# Check for water gap hole
	var rand_val: float = randf()
	if not is_safe_start and rand_val < water_gap_chance:
		# Leave as open water (no ice tile spawned)
		return

	var tile: IceTile = ice_tile_scene.instantiate() as IceTile
	tile.global_position = Vector2(grid_pos.x * tile_size, grid_pos.y * tile_size)
	add_child(tile)

	# Randomize thin ice start state
	if not is_safe_start and rand_val < (water_gap_chance + thin_ice_chance):
		tile.crack_level = randi_range(1, 2) # Start pre-cracked!

	active_tiles[grid_pos] = tile
