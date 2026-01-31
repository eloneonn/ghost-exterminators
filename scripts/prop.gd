@tool
class_name Prop extends CharacterBody2D

@export var activation_radius: float = 80.0
@export var speed: float = 10.0
@export var stupidFleeSpeed = 40.0
@export var health: int = 100;
@export var ghost: bool = false;

@onready var sensor_center: Area2D = $Sensor_Center;
@onready var sensor_top: Area2D = $Sensor_Top;
@onready var sensor_bottom: Area2D = $Sensor_Bottom;
@onready var sensor_left: Area2D = $Sensor_Left;
@onready var sensor_right: Area2D = $Sensor_Right;

#Types of ghost behaviour
enum GhostBehaviour {
	ATTACK,
	STUPID_FLEE
}

@export var ghost_behaviour: GhostBehaviour = GhostBehaviour.ATTACK

#LIT percentage
var top_lit: bool = false
var bottom_lit: bool = false
var left_lit: bool = false
var right_lit: bool = false
var center_lit: bool = false

var sensors_lit: int = 0
var total_points: int = 5

#For stupid fleeing
@export var flee_distance: float = 180.0
@export var bounce_strength: float = 0.6
var flee_direction: Vector2 = Vector2.ZERO
var has_been_lit: bool = false

## Monetary value of the prop
@export var value: int = 100;
@export var texture: Texture2D = null;
## Prop is frozen if the player is shining a flashlight on it
var frozen: bool = false;

@onready var sprite: Sprite2D = $Sprite2D

var player: CharacterBody2D

func _ready():
	if texture != null:
		sprite.texture = texture;
	
	sensor_center.area_entered.connect(_on_enter_area_center_sensor)
	sensor_top.area_entered.connect(_on_enter_area_top_sensor)
	sensor_bottom.area_entered.connect(_on_enter_area_bottom_sensor)
	sensor_left.area_entered.connect(_on_enter_area_left_sensor)
	sensor_right.area_entered.connect(_on_enter_area_right_sensor)
	
	sensor_center.area_exited.connect(_on_exit_area_center_sensor)
	sensor_top.area_exited.connect(_on_exit_area_top_sensor)
	sensor_bottom.area_exited.connect(_on_exit_area_bottom_sensor)
	sensor_left.area_exited.connect(_on_exit_area_left_sensor)
	sensor_right.area_exited.connect(_on_exit_area_right_sensor)
	
	
func _on_enter_area_center_sensor(_area: Area2D):
	center_lit = true;
	update_light_ratio();

func _on_enter_area_top_sensor(_area: Area2D):
	top_lit = true;
	update_light_ratio();

func _on_enter_area_bottom_sensor(_area: Area2D):
	bottom_lit = true;
	update_light_ratio();

func _on_enter_area_left_sensor(_area: Area2D):
	left_lit = true;
	update_light_ratio();

func _on_enter_area_right_sensor(_area: Area2D):
	right_lit = true;
	update_light_ratio();

func _on_exit_area_center_sensor(_area: Area2D):
	center_lit = false;
	update_light_ratio();

func _on_exit_area_top_sensor(_area: Area2D):
	top_lit = false;
	update_light_ratio();

func _on_exit_area_bottom_sensor(_area: Area2D):
	bottom_lit = false;
	update_light_ratio();

func _on_exit_area_left_sensor(_area: Area2D):
	left_lit = false;
	update_light_ratio();

func _on_exit_area_right_sensor(_area: Area2D):
	right_lit = false;
	update_light_ratio();


func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		print("Player found:", player)
		return

	var distance = global_position.distance_to(player.global_position)

	if ghost and distance <= activation_radius:
		match ghost_behaviour:
			GhostBehaviour.ATTACK:
				if sensors_lit < 2:
					follow_player()
			GhostBehaviour.STUPID_FLEE:
				if has_been_lit and sensors_lit <= 2:
					stupid_flee()
	else:
		velocity = Vector2.ZERO
		flee_direction = Vector2.ZERO

func stupid_flee() -> void:
	var distance = global_position.distance_to(player.global_position)

	# Stop fleeing if far enough
	if distance >= flee_distance:
		velocity = Vector2.ZERO
		flee_direction = Vector2.ZERO
		return

	# Pick direction once (slightly dumb)
	if flee_direction == Vector2.ZERO:
		flee_direction = (global_position - player.global_position).normalized()
		flee_direction = flee_direction.rotated(randf_range(-0.4, 0.4))

	velocity = flee_direction * stupidFleeSpeed
	move_and_slide()

	# Handle dumb bounce
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var normal = collision.get_normal()

		# Wall tangent
		var tangent = Vector2(-normal.y, normal.x)
		if tangent.dot(flee_direction) < 0:
			tangent = -tangent

		var reflected = flee_direction.bounce(normal)

		# Strong wall hug
		flee_direction = (tangent * 0.9 + reflected * 0.1).normalized()

		# Never move toward player
		var to_player = (player.global_position - global_position).normalized()
		if flee_direction.dot(to_player) > 0:
			flee_direction = -tangent

		# Very small chaos
		flee_direction = flee_direction.rotated(randf_range(-bounce_strength * 0.2, bounce_strength * 0.2))

func update_light_ratio():
	var lit_count = 0
	if top_lit:
		lit_count += 1
	if bottom_lit:
		lit_count += 1
	if left_lit:
		lit_count += 1
	if right_lit:
		lit_count += 1
	if center_lit:
		lit_count += 1

	sensors_lit = lit_count;
	print("Sensors lit:", sensors_lit, " / ", total_points)

func follow_player() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed

	move_and_slide()

func take_damage(damage: int) -> void:
	print("Prop took damage: ", damage)
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	if ghost:
		GameManager.capture_ghost(self.value)
	else:
		GameManager.destroy_prop(self.value)

	queue_free()
