# extends Node2D
# signal door_triggered
# # Player enters this Area2D to be able to interact with the door.
# @onready var door_area: Area2D = $DoorArea
# @onready var prompt: Label = $Prompt


# # Set this in the Inspector: the scene you want to load when interacting.
# @export var target_scene: PackedScene

# # Optional: if true, the door will trigger automatically when the player enters the area.
# @export var auto_trigger: bool = true

# var player_in_range := false

# func _ready() -> void:
# 	door_area.body_entered.connect(_on_door_area_body_entered)
# 	door_area.body_exited.connect(_on_door_area_body_exited)

# func _unhandled_input(event: InputEvent) -> void:
# 	if player_in_range and event.is_action_pressed("interact"):
# 		door_triggered.emit()


# func _on_door_area_body_entered(body: Node) -> void:
# 	print("Door: Body entered door area: %s" % body.name)

# 	player_in_range = true
# 	prompt.visible = true
# func _on_door_area_body_exited(body: Node) -> void:
# 	if body.is_in_group("player"):
# 		player_in_range = false
# 		prompt.visible = false
extends Node2D

signal interacted

@export var prompt_text: String = "Press E"

@onready var area: Area2D = $InteractArea
@onready var prompt: Label = $Prompt

var player_in_range := false
var current_player: Node = null

func _ready() -> void:
	prompt.visible = false
	prompt.text = prompt_text
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		interacted.emit()

func _on_enter(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	player_in_range = true
	current_player = body
	prompt.text = prompt_text
	prompt.visible = true

func _on_exit(body: Node) -> void:
	if body == current_player:
		player_in_range = false
		current_player = null
		prompt.visible = false

func set_prompt(text: String) -> void:
	prompt_text = text
	if prompt:
		prompt.text = text
