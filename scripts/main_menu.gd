extends MarginContainer

@onready var start_game_btn: Button = %StartGameBtn

func _ready() -> void:
	start_game_btn.pressed.connect(_on_start_game_btn_pressed)

func _on_start_game_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/safehouse_scene.tscn")
