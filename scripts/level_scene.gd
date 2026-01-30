extends Node2D

@onready var door: Node = %Door

func _ready() -> void:
	print("Level Scene ready.")
	# Connect Door's signal to this function
	door.door_triggered.connect(_on_door_triggered)

func _on_door_triggered() -> void:
	print("Transitioning to safehouse scene.")
	get_tree().change_scene_to_file("res://scenes/safehouse_scene.tscn")