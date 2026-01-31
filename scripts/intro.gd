extends CanvasLayer

@onready var night_label: Label = %NightLabel

func _ready() -> void:
	night_label.text = "Night " + str(GameManager.level)
