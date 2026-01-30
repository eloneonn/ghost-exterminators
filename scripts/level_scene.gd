extends Node2D

@onready var door: Node = %Door

func _ready() -> void:
	door.set_prompt("Enter the Safehouse Scene (Press E)")
	door.interacted.connect(_on_door_triggered)

func _on_door_triggered() -> void:
	print("Transitioning to safehouse scene.")
	get_tree().change_scene_to_file("res://scenes/safehouse_scene.tscn")