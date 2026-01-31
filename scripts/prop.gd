class_name Prop extends CharacterBody2D

@export var activation_radius: float = 80.0
@export var speed: float = 50.0
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
	STUPID_FLEE,
	SMART_FLEE
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

#For smart fleeing
@export var smart_flee_speed: float = 60.0
@export var ray_length: float = 24.0
@export var ray_count: int = 9
@export var max_steer_angle: float = 0.4 # radians (~22.5°)
var wall_following := false
var wall_normal := Vector2.ZERO
var slide_velocity: Vector2 = Vector2.ZERO
var target_safe_zone: Vector2 = Vector2.ZERO

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
	add_to_group("props")
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

	if ghost:
		match ghost_behaviour:
			GhostBehaviour.ATTACK:
				if sensors_lit < 2 and distance <= activation_radius * 3.0:
					follow_player()
			GhostBehaviour.STUPID_FLEE:
				if has_been_lit and sensors_lit <= 2:
					stupid_flee()
			GhostBehaviour.SMART_FLEE:
				if has_been_lit and sensors_lit == 0:
					smart_flee(_delta)
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

	# Pick a direction once
	if flee_direction == Vector2.ZERO:
		flee_direction = pick_not_toward_player()

	velocity = flee_direction * stupidFleeSpeed
	move_and_slide()

	# If we collide, just pick a new dumb direction
	if get_slide_collision_count() > 0:
		flee_direction = pick_not_toward_player()

func pick_not_toward_player() -> Vector2:
	var to_player = (player.global_position - global_position).normalized()
	var dir := Vector2.ZERO

	for i in range(8): # try a few times
		dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

		# Reject directions vaguely toward the player
		# dot > 0.3 = somewhat facing player
		if dir.dot(to_player) < 0.6:
			return dir

	# Fallback: directly away (should almost never happen)
	return -to_player


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
	
func smart_flee(_delta: float) -> void:
	if target_safe_zone == Vector2.ZERO:
		choose_safe_zone()
		if target_safe_zone == Vector2.ZERO:
			return

	var desired_dir = (target_safe_zone - global_position).normalized()

	# Only change direction if we are not colliding
	if get_slide_collision_count() == 0:
		velocity = desired_dir * smart_flee_speed

	move_and_slide()

	# Reached safe zone
	if global_position.distance_to(target_safe_zone) < 8:
		target_safe_zone = Vector2.ZERO
		velocity = Vector2.ZERO
		choose_safe_zone()

func is_path_blocked(dir: Vector2) -> bool:
	var ray = PhysicsRayQueryParameters2D.new()
	ray.from = global_position
	ray.to = global_position + dir * 24
	ray.exclude = [self]

	return get_world_2d().direct_space_state.intersect_ray(ray) != {}

func choose_safe_zone():
	var zones = get_tree().get_nodes_in_group("safeZones")
	if zones.size() == 0:
		return

	var closest_dist = INF
	var closest_zone: Node = null
	for zone in zones:
		# Skip the current target_safe_zone if the ghost is already there
		if target_safe_zone != Vector2.ZERO and global_position.distance_to(target_safe_zone) < 16:
			continue

		var dist = global_position.distance_to(zone.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_zone = zone

	if closest_zone:
		target_safe_zone = closest_zone.global_position


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
