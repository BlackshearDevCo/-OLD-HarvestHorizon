extends Node2D

@onready var shop_ui = $Shop_UI

var player_in_range = false;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		shop_ui.visible = !shop_ui.visible
		pass


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
