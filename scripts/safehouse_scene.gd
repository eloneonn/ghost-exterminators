extends Node2D

@onready var door: Node = %Door
@onready var upgrade_desk: Node = %UpgradeDesk
@onready var upgrade_ui: Node = %UpgradeUI
@onready var add_money_button: Button = %GetMoneyButton

func _ready() -> void:
	door.set_prompt("Enter the Level Scene (Press E)")
	door.interacted.connect(_on_door_triggered)
	upgrade_desk.set_prompt("Upgrade your gear (Press E)")
	upgrade_desk.interacted.connect(_on_upgrade_desk_interacted)
	add_money_button.pressed.connect(_on_add_money_button_pressed)

func _on_door_triggered() -> void:
	get_tree().change_scene_to_file("res://scenes/level_scene.tscn")

func _on_add_money_button_pressed() -> void:
	GameManager.add_money(100)
	print("Added money!")
	print("Current money:" + str(GameManager.get_money()))
func _on_upgrade_desk_interacted() -> void:
	if upgrade_ui.visible:
		upgrade_ui.visible = false
	else:
		upgrade_ui.visible = true
	print("Upgrade Desk interacted with.")
