extends CanvasLayer

@onready var battery_label: Label = %BatteryLabel

func _process(_delta: float) -> void:
	if (GameManager != null):
		battery_label.text = "Batteries: " + str(GameManager.get_item_count(Enums.Item.BATTERY))
