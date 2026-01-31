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
@export var damage_per_second: float = 25

# --- Beam geometry (these are your "base stats") ---
@export var base_length: float = 5.0   # pixels
@export var base_width: float = 5.0     # pixels

# --- Overheating ---
@export var max_heat: float = 100.0
@export var heat_per_second: float = 35.0      # while firing
@export var cool_per_second: float = 25.0      # while not firing
@export var overheated_cool_threshold: float = 35.0  # must cool below this to re-enable

var heat: float = 0.0
var is_overheated: bool = false
var is_firing: bool = false
var damage_timer: float = 0.0

var _base_damage_per_second: float
var _base_length: float
var _base_width: float
var _base_max_heat: float
var _base_heat_per_second: float
var _base_cool_per_second: float

@onready var beam_sprite: Sprite2D = $BeamSprite
@onready var hit_area: Area2D = $HitArea
@onready var hit_shape: CollisionPolygon2D = $HitArea/CollisionPolygon2D

func _ready() -> void:
	# _cache_base_stats()
	# _apply_upgrades()
	_set_active(false)
<<<<<<< HEAD
	# _apply_beam_geometry()
=======
>>>>>>> 4eeae9b58502a8237dc967d7480fbf834bf179b0

func _process(delta: float) -> void:
	# Flip gun sprite when rotated to the left side so it doesn't appear upside down
	var pointing_left := rotation > PI / 2.0 or rotation < -PI / 2.0
	beam_sprite.scale.y = -1.0 if pointing_left else 1.0

	# If overheated, you can't fire until cooled enough
	var wants_fire := Input.is_action_pressed("shoot")
	is_firing = wants_fire and not is_overheated

	# Visual + hitbox active only when actually firing
	_set_active(is_firing)

	# Heat logic
	_update_heat(delta, wants_fire)

	# Damage if firing (once per second)
	if is_firing:
		damage_timer += delta
		if damage_timer >= 0.2:
			damage_timer -= 0.2
			deal_damage()
	else:
		damage_timer = 0.0

	_update_beam_color(delta)

func deal_damage() -> void:
	for body in hit_area.get_overlapping_bodies():
		if body is Prop:
			if GameManager.has_item(Enums.Item.GUN_DAMAGE):
				print("Applying damage upgrade")
				damage_per_second += Constants.UPGRADE_GUN_DAMAGE_BONUS
			body.take_damage(damage_per_second)

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
	# beam_sprite.visible = active
	hit_area.monitoring = active
	if not active:
		beam_sprite.modulate.a = 0.4
	else:
		beam_sprite.modulate.a = 1.0

func _update_beam_color(_delta: float) -> void:
	if max_heat <= 0.0:
		return

	var heat_ratio := heat / max_heat

	if is_overheated:
		# Flash between red and dark red
		var t := (sin(Time.get_ticks_msec() / 1000.0 * overheated_flash_speed) + 1.0) * 0.5
		beam_sprite.modulate = hot_color.lerp(Color(0.4, 0.0, 0.0), t)
		var flip_sign := -1.0 if (rotation > PI / 2.0 or rotation < -PI / 2.0) else 1.0
		beam_sprite.scale.y = flip_sign * lerp(0.9, 1.1, t)
	else:
		# Smooth gradient: cool → warm → hot
		if heat_ratio < 0.5:
			var t := heat_ratio / 0.5
			beam_sprite.modulate = cool_color.lerp(warm_color, t)
		else:
			var t := (heat_ratio - 0.5) / 0.5
			beam_sprite.modulate = warm_color.lerp(hot_color, t)

func _cache_base_stats() -> void:
	_base_damage_per_second = damage_per_second
	_base_length = base_length
	_base_width = base_width
	_base_max_heat = max_heat
	_base_heat_per_second = heat_per_second
	_base_cool_per_second = cool_per_second

# func _apply_upgrades() -> void:
# 	print("Applying GhostRay upgrades...")
# 	if GameManager == null:
# 		return

# 	damage_per_second = _base_damage_per_second
# 	base_length = _base_length
# 	base_width = _base_width
# 	max_heat = _base_max_heat
# 	heat_per_second = _base_heat_per_second
# 	cool_per_second = _base_cool_per_second
# 	print(GameManager.has_item(Enums.Item.GUN_DAMAGE), " he has it bruf")
# 	if GameManager.has_item(Enums.Item.GUN_DAMAGE):
# 		print("Applying damage upgrade")
# 		damage_per_second += Constants.UPGRADE_GUN_DAMAGE_BONUS
# 	if GameManager.has_item(Enums.Item.GUN_RANGE):
# 		print("Applying range upgrade")
# 		base_length += Constants.UPGRADE_GUN_RANGE_BONUS
# 		base_width += Constants.UPGRADE_GUN_WIDTH_BONUS

<<<<<<< HEAD
# 	base_width = max(1.0, base_width)
# 	_apply_beam_geometry()
=======
	base_width = max(1.0, base_width)
>>>>>>> 4eeae9b58502a8237dc967d7480fbf834bf179b0

# 	if GameManager.has_item(Enums.Item.GUN_COOLING):
# 		max_heat += Constants.UPGRADE_GUN_MAX_HEAT_BONUS
# 		cool_per_second += Constants.UPGRADE_GUN_COOL_RATE_BONUS
# 		heat_per_second = max(1.0, heat_per_second - Constants.UPGRADE_GUN_HEAT_RATE_REDUCTION)
