extends Resource
class_name PlayerData

@export var SavePos: Vector2

func UpdatePos(position: Vector2):
	SavePos = position
