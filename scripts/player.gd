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
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var thought_label: Label = %ThoughtLabel

var sanity: int = 100;
var battery_charge: int = Constants.BATTERY_MAX_CHARGE;
var _battery_drain_accumulator: float = 0.0;

func _on_light_area_body_entered(body: CharacterBody2D) -> void:
	if body is Prop:
		#body.frozen = true;
		body.has_been_lit = true;

func _on_light_area_body_exited(body: CharacterBody2D) -> void:
	if body is Prop:
		body.frozen = false;

func _ready() -> void:
	debug_light_sprite.visible = false;
	light_area.body_entered.connect(_on_light_area_body_entered)
	light_area.body_exited.connect(_on_light_area_body_exited)

func take_sanity_damage(damage: int) -> void:
	sanity -= damage;
	if sanity <= 0:
		GameManager.end_game(Enums.GameEnding.INSANITY);

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	_update_battery(delta)

	flashlight.visible = flashlight_enabled;

	flashlight.visible = flashlight_enabled
	pointlight.visible = !flashlight_enabled

	ghost_ray.visible = gun_enabled

	_update_aim()

	move_and_slide()


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
			battery_charge = Constants.BATTERY_MAX_CHARGE
		else:
			flashlight_enabled = false


func _update_aim() -> void:
	var mouse_position := get_global_mouse_position()
	var direction := (mouse_position - global_position).normalized()
	var angle := direction.angle()

	if direction.x > 0:
		sprite.flip_h = true
	elif direction.x < 0:
		sprite.flip_h = false

	flashlight.rotation = angle
	ghost_ray.rotation = angle

	# Optional: position the gun slightly in front of the player
	ghost_ray.position = direction * 10.0
	
func _unhandled_input(event: InputEvent) -> void:	
	if event.is_action_pressed("flashlight"):
		flashlight_enabled = !flashlight_enabled;

func set_flashlight_rotation() -> void:
	var mouse_position := get_global_mouse_position()
	var direction := (mouse_position - global_position).normalized()
	var angle := direction.angle()

	flashlight.rotation = angle
	ghost_ray.rotation = angle

func show_thought(thought: String, delay: float) -> void:
	await get_tree().create_timer(delay).timeout

	thought_label.text = thought
	animation_player.play("thought")