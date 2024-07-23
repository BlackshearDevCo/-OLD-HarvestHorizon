extends Node

@export var inventory_item_scene_path = "res://scenes/Inventory_Item.tscn"

@export var crop_index: int = 0
@export var seed_indexes: Dictionary = {
	0: "carrot",
	1: "turnip",
	2: "wheat",
	3: "rye",
	4: "corn",
	5: "tomato",
	6: "pumpkin",
	7: "jackolantern",
}
@export var seed_atlas_croods: Dictionary = {
	"carrot": {
		"seed": Vector2i(8,5),
		"growing": Vector2i(8,4),
		"mature": Vector2i(8,3),
	},
	"turnip": {
		"seed": Vector2i(8,5),
		"growing": Vector2i(11,2),
		"mature": Vector2i(10,2),
	},
	"wheat": {
		"seed": Vector2i(10,5),
		"growing": Vector2i(10,4),
		"mature": Vector2i(10,3),
	},
	"rye": {
		"seed": Vector2i(8,6),
		"growing": Vector2i(10,6),
		"mature": Vector2i(11,6),
	},
	"corn": {
		"seed": Vector2i(11,5),
		"growing": Vector2i(11,4),
		"mature": Vector2i(11,3),
	},
	"tomato": {
		"seed": Vector2i(9,5),
		"growing": Vector2i(9,4),
		"mature": Vector2i(9,3),
	},
	"pumpkin": {
		"seed": Vector2i(6,3),
		"growing": Vector2i(7,3),
		"mature": Vector2i(4,0),
	},
	"jackolantern": {
		"seed": Vector2i(6,3),
		"growing": Vector2i(7,3),
		"mature": Vector2i(5,0),
	},
}
@export var crop_type_texture: Dictionary = {
	"carrot": {
		"seed": load("res://assets/Kenny/pngs/tile_0088.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0072.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0056.png"),
	},
	"turnip": {
		"seed": load("res://assets/Kenny/pngs/tile_0088.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0043.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0042.png"),
	},
	"wheat": {
		"seed": load("res://assets/Kenny/pngs/tile_0090.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0074.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0058.png"),
	},
	"rye": {
		"seed": load("res://assets/Kenny/pngs/tile_0104.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0105.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0107.png"),
	},
	"corn": {
		"seed": load("res://assets/Kenny/pngs/tile_0091.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0075.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0059.png"),
	},
	"tomato": {
		"seed": load("res://assets/Kenny/pngs/tile_0089.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0073.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0057.png"),
	},
	"pumpkin": {
		"seed": load("res://assets/Kenny/pngs/tile_0054.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0055.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0004.png"),
	},
	"jackolantern": {
		"seed": load("res://assets/Kenny/pngs/tile_0054.png"),
		"growing": load("res://assets/Kenny/pngs/tile_0055.png"),
		"mature": load("res://assets/Kenny/pngs/tile_0005.png"),
	},
}

var inventory = []
var inventory_index = 0;
var money = 5

# player reference
var player_node: Node = null
@onready var inventory_slot_scene = preload("res://scenes/inventory_slot.tscn")

signal inventory_updated

func _ready():
	inventory.resize(27)


func get_current_inventory_item():
	return inventory[inventory_index]


func set_inventory_index(index):
	inventory_index = index
	
	
func add_item(item: Dictionary):
	var empty_index = null
	var item_found = false

	for i in inventory.size():
		if inventory[i] != null and inventory[i]["type"] == item["type"] and inventory[i]["name"] == item["name"]:
			inventory[i]["quantity"] += item["quantity"]
			inventory_updated.emit()
			item_found = true
			return true
		elif empty_index == null and inventory[i] == null:
			empty_index = i
	
	if item_found == false:
		inventory[empty_index] = item
		inventory_updated.emit()


func add_items(items: Array):
	for i in range(inventory.size()):
		for item in items:
			if inventory[i] != null and inventory[i]["type"] == item["type"] and inventory[i]["name"] == item["name"]:
				inventory[i]["quantity"] += item["quantity"]
				inventory_updated.emit()
				return true
			elif inventory[i] == null:
				inventory[i] = item
				inventory_updated.emit()
				return true
		return false
	
func remove_item(item: Dictionary):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item["type"] and inventory[i]["name"] == item["name"]:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false


func get_money():
	return money


func add_money(amount: int):
	money += amount


func spend_money(amount: int):
	money -= amount
	
	
func increase_inventory_size():
	inventory_updated.emit()


func set_player_reference(player):
	player_node = player

