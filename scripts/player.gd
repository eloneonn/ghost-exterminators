class_name Player
extends CharacterBody2D

@export var speed: float = 50.0
@export var flashlight_enabled: bool = true
@export var gun_enabled: bool = true

@onready var flashlight: Node2D = %Flashlight
@onready var pointlight: Node2D = %PointLight
@onready var ghost_ray: Node2D = %GhostRay  # or $GhostRay if not unique
@onready var debug_light_sprite: Sprite2D = %DebugLightSprite
@onready var light_area: Area2D = %LightArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var thought_label: Label = %ThoughtLabel

@onready var additivelight: PointLight2D = %Flashlight/AdditiveLight
@onready var subtractivelight: PointLight2D = %Flashlight/SubtractiveLight
@onready var light_area_collision: CollisionPolygon2D = %LightArea/CollisionPolygon2D
@onready var footstep_player: AudioStreamPlayer2D = $FootstepPlayer
@onready var flashlight_player: AudioStreamPlayer2D = $FlashlightPlayer
@onready var battery_player: AudioStreamPlayer2D = $BatteryPlayer

var _footstep_timer: float = 0.0

var sanity: int = 125;
var battery_max_charge: int = Constants.BATTERY_MAX_CHARGE
var battery_charge: int = Constants.BATTERY_MAX_CHARGE;
var _battery_drain_accumulator: float = 0.0;
var _sanity_bleed_accumulator: float = 0.0;
var _base_speed: float

func _ready() -> void:
	GameManager.quota_reached.connect(_on_quota_reached)
	debug_light_sprite.visible = false;
	light_area.body_entered.connect(_on_light_area_body_entered)
	light_area.body_exited.connect(_on_light_area_body_exited)
	var step_stream: AudioStream = preload("res://sfx/step.wav") as AudioStream
	if step_stream:
		footstep_player.stream = step_stream
		footstep_player.pitch_scale = randf_range(0.8, 1.2)
		footstep_player.volume_db = randf_range(-6.0, -2.0)
		footstep_player.bus = "SFX"
	var flashlight_stream: AudioStream = preload("res://sfx/flashlight.wav") as AudioStream
	if flashlight_stream:
		flashlight_player.stream = flashlight_stream
		flashlight_player.bus = "SFX"
	var battery_stream: AudioStream = preload("res://sfx/battery.wav") as AudioStream
	if battery_stream:
		battery_player.stream = battery_stream
		battery_player.bus = "SFX"
	_cache_base_stats()
	_apply_upgrades()
	# if ghost_ray is GhostRay:
	# 	ghost_ray._apply_upgrades()

func _process(_delta: float) -> void:
	if (GameManager.has_item(Enums.Item.BETTER_FLASHLIGHT)):
		additivelight.texture = preload("res://assets/beam_3.png")
		subtractivelight.texture = preload("res://assets/beam_3.png")
		additivelight.texture_scale = 0.15
		subtractivelight.texture_scale = 0.15
		light_area_collision.scale = Vector2(1.5, 1.5)
	else:
		additivelight.texture = preload("res://assets/beam_2.png")
		subtractivelight.texture = preload("res://assets/beam_2.png")
		additivelight.texture_scale = 0.1
		subtractivelight.texture_scale = 0.1
		light_area_collision.scale = Vector2(1.0, 1.0)

func _on_light_area_body_entered(body: CharacterBody2D) -> void:
	if body is Prop:
		#body.frozen = true;
		body.has_been_lit = true;

func _on_light_area_body_exited(body: CharacterBody2D) -> void:
	if body is Prop:
		body.frozen = false;

func _on_quota_reached(quota: int) -> void:
	show_thought("I've reached my quota of " + str(quota) + " ghosts! I should go back home...", 0.0)

func take_sanity_damage(damage: int) -> bool:
	sanity -= damage;
	animation_player.play("hurt")

	await get_tree().create_timer(0.7).timeout

	if sanity <= 0:
		GameManager.end_timer()
		GameManager.end_game(Enums.GameEnding.INSANITY);
		return true
		
	return false

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	_update_battery(delta)
	_update_sanity_bleed(delta)

	flashlight.visible = flashlight_enabled;

	flashlight.visible = flashlight_enabled
	pointlight.visible = !flashlight_enabled

	ghost_ray.visible = gun_enabled

	_update_aim()

	move_and_slide()

	_update_footsteps(delta)
	_update_walk_animation()


func _update_footsteps(delta: float) -> void:
	if not is_instance_valid(footstep_player) or footstep_player.stream == null:
		return
	if velocity.length() > 0:
		_footstep_timer += delta
		if _footstep_timer >= (0.35 if GameManager.has_item(Enums.Item.PLAYER_SPEED) else 0.55):
			_footstep_timer = 0.0
			footstep_player.pitch_scale = randf_range(0.6, 1.4)
			footstep_player.volume_db = randf_range(-6.0, -2.0)
			footstep_player.play()
	else:
		_footstep_timer = 0.0

func _update_walk_animation() -> void:
	if velocity.length() > 0:
		if animated_sprite.animation != "walk":
			animated_sprite.play("walk")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func _update_battery(delta: float) -> void:
	if not flashlight_enabled:
		return

	_battery_drain_accumulator += delta
	while _battery_drain_accumulator >= 1.0 and battery_charge > 0:
		_battery_drain_accumulator -= 1.0
		battery_charge -= 1

	if battery_charge <= 0:
		_battery_drain_accumulator = 0.0
		if GameManager.has_item(Enums.Item.BATTERY):
			GameManager.remove_item(Enums.Item.BATTERY)
			battery_charge = battery_max_charge
			if is_instance_valid(battery_player) and battery_player.stream != null:
				battery_player.play()
			if !GameManager.has_item(Enums.Item.BATTERY):
				show_thought("There goes my last battery! Gotta be quick!", 0.0)
		else:
			flashlight_enabled = false


func _update_sanity_bleed(delta: float) -> void:
	## When out of flashlight (no charge and no spare batteries), lose a little sanity every second.
	if battery_charge > 0 or GameManager.has_item(Enums.Item.BATTERY):
		_sanity_bleed_accumulator = 0.0
		return

	_sanity_bleed_accumulator += delta
	while _sanity_bleed_accumulator >= 1.0:
		_sanity_bleed_accumulator -= 1.0
		take_sanity_damage(Constants.SANITY_BLEED_NO_FLASHLIGHT)


func _update_aim() -> void:
	var mouse_position := get_global_mouse_position()
	var direction := (mouse_position - global_position).normalized()
	var angle := direction.angle()

	if direction.x > 0:
		sprite.flip_h = true
		animated_sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false
		animated_sprite.flip_h = false

	# flashlight.rotation = angle
	ghost_ray.rotation = angle

	# Optional: position the gun slightly in front of the player
	ghost_ray.position = direction * 10.0
	
func _unhandled_input(event: InputEvent) -> void:	
	if event.is_action_pressed("flashlight"):
		flashlight_enabled = !flashlight_enabled
		if is_instance_valid(flashlight_player) and flashlight_player.stream != null:
			flashlight_player.play()

func show_thought(thought: String, delay: float) -> void:
	if get_tree() != null:
		await get_tree().create_timer(delay).timeout

	thought_label.text = thought
	animation_player.play("thought")

func _cache_base_stats() -> void:
	_base_speed = speed

func _apply_upgrades() -> void:
	if GameManager == null:
		return

	speed = _base_speed
	battery_max_charge = Constants.BATTERY_MAX_CHARGE

	if GameManager.has_item(Enums.Item.PLAYER_SPEED):
		speed += Constants.UPGRADE_PLAYER_SPEED_BONUS

	if GameManager.has_item(Enums.Item.PLAYER_BATTERY):
		battery_max_charge += Constants.UPGRADE_PLAYER_BATTERY_BONUS

	battery_charge = battery_max_charge
