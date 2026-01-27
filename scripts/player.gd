class_name Player extends CharacterBody2D

@export var speed: float = 200.0

@onready var flashlight: Node2D = %Flashlight

func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	set_flashlight_rotation()
	
	move_and_slide()

func set_flashlight_rotation() -> void:
	var mouse_position := get_global_mouse_position()
	var direction := (mouse_position - position).normalized()
	flashlight.rotation = direction.angle() 
