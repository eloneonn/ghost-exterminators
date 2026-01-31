class_name Player
extends CharacterBody2D

@export var speed: float = 50.0
@export var flashlight_enabled: bool = true
@export var gun_enabled: bool = true

@onready var flashlight: Node2D = %Flashlight
@onready var pointlight: Node2D = %PointLight
@onready var ghost_ray: Node2D = %GhostRay  # or $GhostRay if not unique

func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	flashlight.visible = flashlight_enabled
	pointlight.visible = !flashlight_enabled

	ghost_ray.visible = gun_enabled

	_update_aim()

	move_and_slide()

func _update_aim() -> void:
	var mouse_position := get_global_mouse_position()
	var direction := (mouse_position - global_position).normalized()
	var angle := direction.angle()

	flashlight.rotation = angle
	ghost_ray.rotation = angle
