class_name Prop extends CharacterBody2D

@export var activation_radius: float = 80.0
@export var jumpscare_radius: float = 32.0
@export var speed: float = 50.0
@export var stupidFleeSpeed = 40.0
@export var health: int = 100;
@export var ghost: bool = false;
@export var sanity_damage: int = 25;
@export var jumpscare_delay: float = 3;
@export var post_jumpscare_slow_duration: float = 3
@export var post_jumpscare_speed_multiplier: float = 0.35
@export var attack_stop_distance: float = 18.0

@onready var sensor_center: Area2D = $Sensor_Center;
@onready var sensor_top: Area2D = $Sensor_Top;
@onready var sensor_bottom: Area2D = $Sensor_Bottom;
@onready var sensor_left: Area2D = $Sensor_Left;
@onready var sensor_right: Area2D = $Sensor_Right;
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var shake_anim_player: AnimationPlayer = %ShakeAnimation;
@onready var flash_anim_player: AnimationPlayer = %FlashAnimation;
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D;

signal jumpscared

var jumpscaring: bool = false
var _slow_until_msec: int = 0

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
@onready var prop_sound_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player: CharacterBody2D

const SFX_SMASH := "res://sfx/smash.ogg"
const SFX_BREAK := "res://sfx/break.wav"
# Preloaded - DirAccess fails on web export (HTML5)
const PROPS_SFX_STREAMS: Array[AudioStream] = [
	preload("res://sfx/props/clink.wav"),
	preload("res://sfx/props/creak.wav"),
	preload("res://sfx/props/drawer.wav"),
	preload("res://sfx/props/rattling.wav"),
]
var _prop_sound_timer: Timer

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

	if !ghost:
		return

	# Timer to play a random prop sound every 10 seconds
	_prop_sound_timer = Timer.new()
	_prop_sound_timer.wait_time = randf_range(15.0, 50.0)
	_prop_sound_timer.one_shot = false
	_prop_sound_timer.timeout.connect(_play_random_prop_sound)
	add_child(_prop_sound_timer)
	_prop_sound_timer.start()


func _play_sfx(path: String, audio_player: AudioStreamPlayer2D) -> void:
	if not is_instance_valid(audio_player):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream:
		audio_player.stream = stream
		audio_player.pitch_scale = 1.0
		audio_player.pitch_scale = randf_range(0.8, 1.2)
		audio_player.volume_db = 0.0
		audio_player.bus = "SFX"
		audio_player.play()

func _play_random_prop_sound() -> void:
	if PROPS_SFX_STREAMS.is_empty() or not is_instance_valid(prop_sound_player):
		return
	var stream: AudioStream = PROPS_SFX_STREAMS[randi() % PROPS_SFX_STREAMS.size()]
	prop_sound_player.stream = stream
	prop_sound_player.pitch_scale = randf_range(0.8, 1.2)
	prop_sound_player.volume_db = randf_range(-12.0, -5.0)
	prop_sound_player.bus = "SFX"
	prop_sound_player.play()


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

func jumpscare() -> void:
	jumpscared.emit()
	var camera: Camera = get_tree().get_first_node_in_group("camera");

	animation_player.play("jumpscare")
	velocity = Vector2.ZERO

	camera.shake(1.0, 10.0, 10.0)
	
	var player_died = player.take_sanity_damage(sanity_damage);

	if player_died:
		queue_free()
		return

	player.show_thought("Aaaaaah!", 0.0)

	await get_tree().create_timer(jumpscare_delay).timeout

	jumpscaring = false
	_slow_until_msec = Time.get_ticks_msec() + int(post_jumpscare_slow_duration * 1000.0)

func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var distance = global_position.distance_to(player.global_position)

	if ghost:
		# print(distance)
		
		if distance <= jumpscare_radius and !jumpscaring:
			jumpscaring = true
			jumpscare()
			return

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
	var distance := global_position.distance_to(player.global_position)
	if distance <= attack_stop_distance:
		velocity = Vector2.ZERO
		return

	var direction = (player.global_position - global_position).normalized()
	var current_speed := speed
	if Time.get_ticks_msec() < _slow_until_msec:
		current_speed *= post_jumpscare_speed_multiplier
	velocity = direction * current_speed

	move_and_slide()

func take_damage(damage: int) -> void:
	var shake_anims := ["Shake", "Shake 2", "Shake 3"]
	shake_anim_player.play(shake_anims[randi() % shake_anims.size()])
	flash_anim_player.play("flash")
	_play_sfx(SFX_SMASH, prop_sound_player)

	print("Prop took damage: ", damage)
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	sprite.visible = false
	collision_shape_2d.disabled = true

	if ghost:
		GameManager.capture_ghost(self.value)
	else:
		GameManager.destroy_prop(self.value)

	# Play die SFX: smash + break (reparent so sounds finish after we're freed)
	var break_player := AudioStreamPlayer2D.new()
	break_player.bus = "SFX"
	add_child(break_player)
	_play_sfx(SFX_SMASH, prop_sound_player)
	_play_sfx(SFX_BREAK, break_player)
	get_tree().current_scene.add_child(prop_sound_player)
	get_tree().current_scene.add_child(break_player)
	prop_sound_player.finished.connect(prop_sound_player.queue_free)
	break_player.finished.connect(break_player.queue_free)

	animation_player.play("die")
	await animation_player.animation_finished

	queue_free()
