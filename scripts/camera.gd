class_name Camera
extends Camera2D

var _shake_remaining: float = 0.0
var _shake_duration: float = 0.0
var _shake_frequency: float = 0.0
var _shake_amplitude: float = 0.0
var _shake_interval: float = 0.0
var _shake_offset: Vector2 = Vector2.ZERO

func shake(duration: float, frequency: float, amplitude: float) -> void:
	_shake_duration = duration
	_shake_remaining = duration
	_shake_frequency = frequency
	_shake_amplitude = amplitude
	_shake_interval = 0.0
	_shake_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1))

func _process(delta: float) -> void:
	if _shake_remaining <= 0.0:
		offset = Vector2.ZERO
		return

	_shake_remaining -= delta

	_shake_interval -= delta
	if _shake_interval <= 0.0:
		_shake_interval = 1.0 / _shake_frequency if _shake_frequency > 0.0 else 0.016
		_shake_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1))

	var decay: float = _shake_remaining / _shake_duration
	offset = _shake_offset * _shake_amplitude * decay