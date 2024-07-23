extends CharacterBody2D

const SPEED = 100.0
const SPRINT_SPEED = 200.0
const JUMP_VELOCITY = -300.0

# Coyote frame variables
@export var coyote_time = 0.1
var coyote_timer = 0.0
var on_ground: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var inventory_ui = $InventoryUI
@onready var crop_type_texture = Global.crop_type_texture
@onready var inventory_item_scene_path = Global.inventory_item_scene_path


var additonal_jump_used = false;

func _ready():
	Global.set_player_reference(self)

func _process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer > 0.0:
			# Handle first jump
			velocity.y = JUMP_VELOCITY
			additonal_jump_used = false
			coyote_timer = 0.0
		elif !is_on_floor() and additonal_jump_used != true:
			# Handle second jump
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0.0
			additonal_jump_used = true
		
		
	if is_on_floor():
		additonal_jump_used = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	
	if direction < 0:
		animated_sprite_2d.flip_h = false
	elif direction > 0:
		animated_sprite_2d.flip_h = true
	
	if direction:
		var is_sprinting = Input.is_action_pressed("sprint")
		animated_sprite_2d.play("walk")
		animated_sprite_2d.speed_scale = 1
		if is_sprinting:
			animated_sprite_2d.speed_scale = 2
		var move_speed = SPRINT_SPEED if is_sprinting else SPEED
		velocity.x = direction * move_speed
	else:
		animated_sprite_2d.stop()
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if is_on_floor():
		#on_ground = true
		coyote_timer = coyote_time
	else:
		#on_ground = false
		coyote_timer -= delta
	
func _input(event):
	if event.is_action_pressed("ui_inventory"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused
	
func _on_button_pressed():
	# Test action
	var item = {
		"quantity": 5,
		"type": "seed",
		"name": "carrot",
		"texture": crop_type_texture["carrot"]["seed"],
		"scene_path": inventory_item_scene_path
	}
	var cost = 1
	
	if Global.player_node and Global.get_money() >= cost:
		Global.spend_money(cost)
		Global.add_item(item)
	

#const save_file_path = "user://save/"
#const save_file_name = "PlayerSave.tres"
#var player_data = PlayerData.new()
	
#func verify_save_directory(path: String):
	#DirAccess.make_dir_absolute(path)
	
#func clear_data():
	#ResourceSaver.save(PlayerData.new(), save_file_path + save_file_name)	

#func load_data():
	#var player_load_data = ResourceLoader.load(save_file_path + save_file_name)
	#if player_load_data:
		#player_data = player_load_data.duplicate(true)
		#on_start_load()
		#
#func on_start_load():
	#self.position = player_data.SavePos

#func save_data():
	#ResourceSaver.save(player_data, save_file_path + save_file_name)

