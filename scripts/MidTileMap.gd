extends TileMap

@onready var tile_map: TileMap = self
@onready var player: CharacterBody2D = $"../Player"

const TILEMAP_ATLAS_SOURCE = 0
@onready var crop_index = Global.crop_index
@onready var seed_indexes = Global.seed_indexes
@onready var seed_atlas_croods = Global.seed_atlas_croods
@onready var crop_type_texture = Global.crop_type_texture
@onready var inventory_item_scene_path = "res://scripts/Inventory_Item.gd"

const growth_stages = {
	0: "seed",
	1: "growing",
	2: "mature"
}

const growth_time = {
	"seed": 10,
	"growing": 20
}

const CROP_LAYER = 1
const TERAIN_LAYER = 2

var crops: Dictionary = {} 

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)


func plant_crop():
	var cell_position = get_player_position()
	var inventory_item = Global.get_current_inventory_item()
	if inventory_item:
		if inventory_item["type"] == "seed" and inventory_item["quantity"] > 0:
			var crop_type = inventory_item["name"]
			var tile_approved = check_tile_beneath_player(cell_position)
			if tile_approved:
				place_crop(cell_position, seed_atlas_croods[crop_type]["seed"], inventory_item)


func check_tile_beneath_player(position: Vector2i):
	var beneath_tile_data = get_cell_beneath_player(position)
	if beneath_tile_data:
		var can_plant_seed = beneath_tile_data.get_custom_data("can_plant_seed")
		var is_obstructed = check_layers_for_obstruction(position)
		return can_plant_seed and not is_obstructed


func get_crop_type_data(position: Vector2i):
	var crop_data = tile_map.get_cell_tile_data(CROP_LAYER, position)
	if crop_data:
		return crop_data.get_custom_data("crop_type")		


func place_crop(position: Vector2i, atlas_coords: Vector2i, item: Dictionary):
	tile_map.set_cell(CROP_LAYER, position, TILEMAP_ATLAS_SOURCE, atlas_coords)
	crops[position] = {"stage": growth_stages[0], "timer": 0, "crop_type": item["name"]}
	Global.remove_item(item)


func harvest_crop(crop_index: int):
	var cell_position = get_player_position()
	var tile_data: TileData = tile_map.get_cell_tile_data(CROP_LAYER, cell_position)
	if tile_data:
		var is_harvestable = tile_data.get_custom_data("is_harvestable")
		#var texture = tile_data.get_custom_data("texture")
		if is_harvestable:
			var crop_type = get_crop_type_data(cell_position)
			Global.add_item({
				"quantity": 1,
				"type": "crop",
				"name": crop_type,
				"texture": crop_type_texture[crop_type]["mature"],
				"scene_path": inventory_item_scene_path
			})
			Global.add_money(1)
		tile_map.erase_cell(CROP_LAYER, cell_position)
		
		
func get_cell_beneath_player(position: Vector2i):
	var cell_beneath_player = Vector2i(position.x, position.y + 1)
	var beneath_tile_data: TileData = tile_map.get_cell_tile_data(TERAIN_LAYER, cell_beneath_player)
	return beneath_tile_data
	
	
func get_player_position():
	var player_position = player.global_position
	var cell_position = local_to_map(player_position)
	return cell_position
	
	
func check_layers_for_obstruction(position: Vector2i):
	var terrain_tile_data: TileData = tile_map.get_cell_tile_data(TERAIN_LAYER, position)
	var crop_tile_data: TileData = tile_map.get_cell_tile_data(CROP_LAYER, position)
	if !terrain_tile_data and !crop_tile_data:
		return false
	else:
		return true


func advance_growth_stage(position: Vector2i):
	var current_stage = crops[position]["stage"]
	var next_stage = get_next_stage(current_stage)
	var crop_type = crops[position]["crop_type"]
	if next_stage:
		crops[position]["stage"] = next_stage
		crops[position]["timer"] = 0
		tile_map.set_cell(CROP_LAYER, position, TILEMAP_ATLAS_SOURCE, seed_atlas_croods[crop_type][next_stage])
		
		
func get_next_stage(current_stage: String) -> String:
	match current_stage:
		"seed":
			return "growing"
		"growing":
			return "mature"
		_:
			return ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for position in crops.keys():
		#crops[position]["timer"] += delta + randi_range(-1, 1) # Adds variation to growth rate
		crops[position]["timer"] += delta * 10	
		var current_stage = crops[position]["stage"]
		if current_stage != growth_stages[2] and crops[position]["timer"] >= growth_time[current_stage]:
			advance_growth_stage(position)
	
	if Input.is_action_just_pressed("change_crop_forwards"):
		var new_crop_index = crop_index + 1
		if new_crop_index < seed_indexes.size():
			#crop_index = new_crop_index
			Global.set_inventory_index(new_crop_index)
		else:
			#crop_index = 0
			Global.set_inventory_index(0)
	
	if Input.is_action_just_pressed("change_crop_backwards"):
		var new_crop_index = crop_index - 1
		if new_crop_index >= 0:
			#crop_index = new_crop_index
			Global.set_inventory_index(new_crop_index)
		else:
			#crop_index = seed_indexes.size() - 1
			Global.set_inventory_index(seed_indexes.size() - 1)

	if Input.is_action_just_pressed("plant_crop"):
		plant_crop()
			
	if Input.is_action_just_pressed("harvest_crop"):
		harvest_crop(crop_index)

#const save_file_path = "user://save/"
#const save_file_name = "TileMap.tres"
#var tile_map_data = TileMapData.new()
#var save_dict = {"crop_tiles": []}
	
#func clear_data():
	#ResourceSaver.save(TileMapData.new(), save_file_path + save_file_name)	
	
#func load_data():
	#var tile_map_load_data = ResourceLoader.load(save_file_path + save_file_name)
	#if tile_map_load_data:
		#tile_map_data = tile_map_load_data.duplicate(true)
		#on_start_load()
		
#func on_start_load():
	#var crop_tiles = tile_map_data.SaveCells.get("crop_tiles")
	#if crop_tiles:
		#for crop in crop_tiles:
			#place_crop(Vector2i(crop.pos_x, crop.pos_y), Vector2i(crop.atlas_coords_x, crop.atlas_coords_y))
	
#func save_data():
	#ResourceSaver.save(tile_map_data, save_file_path + save_file_name)	
	
	#func save_crops():
	#var tile_map_cells = tile_map.get_used_cells(CROP_LAYER)
	#for cell: Vector2i in tile_map_cells:
		#var tile_data: TileData = tile_map.get_cell_tile_data(CROP_LAYER, cell)
		#var is_plant = tile_data.get_custom_data("is_plant")
		#var atlas_coords = get_cell_atlas_coords(CROP_LAYER, cell)
		#if is_plant:
			#save_dict["crop_tiles"].push_back({
				#"pos_x": cell.x,
				#"pos_y": cell.y,
				#"atlas_coords_x": atlas_coords.x,
				#"atlas_coords_y": atlas_coords.y,
			#})
	#if tile_map_cells.size() == 0: save_dict["crop_tiles"].clear()
	#tile_map_data.UpdateCells(save_dict)

