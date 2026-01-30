extends Node2D

@onready var door: Node = %Door

func _ready() -> void:
	# Connect Door's signal to this function
	door.door_triggered.connect(_on_door_triggered)

func _on_door_triggered() -> void:
	get_tree().change_scene_to_file("res://scenes/level_scene.tscn")