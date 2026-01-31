extends Node2D
class_name GhostRay

signal heat_changed(current: float, max_heat: float)
signal overheated_changed(is_overheated: bool)
# --- Visuals ---
@export var cool_color: Color = Color(0.7, 0.9, 1.0)     # light blue / ghosty
@export var warm_color: Color = Color(1.0, 0.8, 0.3)     # yellow/orange
@export var hot_color: Color = Color(1.0, 0.2, 0.2)      # red
@export var overheated_flash_speed: float = 8.0
# --- Damage ---
@export var damage_per_second: float = 25.0

# --- Beam geometry (these are your "base stats") ---
@export var base_length: float = 5.0   # pixels
@export var base_width: float = 5.0     # pixels

# Upgrade multipliers (start at 1, upgrades modify these)
var length_mult: float = 1.0
var width_mult: float = 1.0   # < 1.0 makes it narrower

# --- Overheating ---
@export var max_heat: float = 100.0
@export var heat_per_second: float = 35.0      # while firing
@export var cool_per_second: float = 25.0      # while not firing
@export var overheated_cool_threshold: float = 35.0  # must cool below this to re-enable

var heat: float = 0.0
var is_overheated: bool = false
var is_firing: bool = false

@onready var beam_sprite: Sprite2D = $BeamSprite
@onready var hit_area: Area2D = $HitArea
@onready var hit_shape: CollisionShape2D = $HitArea/CollisionShape2D

func _ready() -> void:
	_set_active(false)
	_apply_beam_geometry()

func _process(delta: float) -> void:
	# If overheated, you can't fire until cooled enough
	var wants_fire := Input.is_action_pressed("shoot")
	is_firing = wants_fire and not is_overheated

	# Visual + hitbox active only when actually firing
	_set_active(is_firing)

	# Heat logic
	_update_heat(delta, wants_fire)

	# Damage if firing
	if is_firing:
		_damage_overlaps(delta)

	_update_beam_color(delta)

func _damage_overlaps(delta: float) -> void:
	for body in hit_area.get_overlapping_bodies():
		if body.is_in_group("ghost") and body.has_method("apply_ghost_ray"):
			body.apply_ghost_ray(damage_per_second, delta)

func _update_heat(delta: float, wants_fire: bool) -> void:
	var prev_heat := heat
	var prev_overheated := is_overheated

	if wants_fire and not is_overheated:
		heat += heat_per_second * delta
	else:
		heat -= cool_per_second * delta

	heat = clamp(heat, 0.0, max_heat)

	# Enter overheat
	if heat >= max_heat and not is_overheated:
		is_overheated = true

	# Exit overheat (hysteresis so it feels good)
	if is_overheated and heat <= overheated_cool_threshold:
		is_overheated = false

	# Emit signals only if changed (nice for UI)
	if heat != prev_heat:
		heat_changed.emit(heat, max_heat)

	if is_overheated != prev_overheated:
		overheated_changed.emit(is_overheated)

func _set_active(active: bool) -> void:
	beam_sprite.visible = active
	hit_area.monitoring = active
	if not active:
		beam_sprite.modulate.a = 0.4
	else:
		beam_sprite.modulate.a = 1.0

# --- Upgrade API ---
# Call these from your upgrade system / shop UI
func upgrade_longer(amount: float) -> void:
	# e.g. amount = 0.15 means +15% length
	length_mult += amount
	_apply_beam_geometry()

func upgrade_narrower(amount: float) -> void:
	# e.g. amount = 0.10 means -10% width
	width_mult = max(0.2, width_mult - amount)
	_apply_beam_geometry()

func upgrade_cooling(amount: float) -> void:
	# e.g. +5 cool rate
	cool_per_second += amount

func upgrade_overheat_capacity(amount: float) -> void:
	# e.g. +20 max heat
	max_heat += amount
	heat = clamp(heat, 0.0, max_heat)
	heat_changed.emit(heat, max_heat)

func _apply_beam_geometry() -> void:
	var length := base_length * length_mult
	var width := base_width * width_mult

	# Update collision rectangle
	var rect := hit_shape.shape as RectangleShape2D
	if rect:
		rect.size = Vector2(length, width)

	# # Push hitbox forward so it starts at muzzle (not centered on player)
	# hit_shape.position = Vector2(length * 0.5, 0)

	# Update beam sprite visuals to match (assumes sprite points to the right)
	# You can do either scale or region; scale is fine for a placeholder.
	beam_sprite.position = Vector2(length * 0.5, 0)

	# If your texture is 1x1 or small, scaling works great.
	# Scale X to length, Y to width (tweak divisor based on your texture size)
	beam_sprite.scale = Vector2(length / 64.0, width / 64.0)

func _update_beam_color(delta: float) -> void:
	if max_heat <= 0.0:
		return

	var heat_ratio := heat / max_heat

	if is_overheated:
		# Flash between red and dark red
		var t := (sin(Time.get_ticks_msec() / 1000.0 * overheated_flash_speed) + 1.0) * 0.5
		beam_sprite.modulate = hot_color.lerp(Color(0.4, 0.0, 0.0), t)
		beam_sprite.scale.y *= lerp(0.9, 1.1, t)
	else:
		# Smooth gradient: cool → warm → hot
		if heat_ratio < 0.5:
			var t := heat_ratio / 0.5
			beam_sprite.modulate = cool_color.lerp(warm_color, t)
		else:
			var t := (heat_ratio - 0.5) / 0.5
			beam_sprite.modulate = warm_color.lerp(hot_color, t)
