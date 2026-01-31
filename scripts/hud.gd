extends CanvasLayer

@onready var battery_label: Label = %BatteryLabel
@onready var quota_label: Label = %QuotaLabel
@onready var sanity_label: Label = %SanityLabel

func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		battery_label.text = "Battery: %d/%d (%d spare)" % [
			player.battery_charge,
			Constants.BATTERY_MAX_CHARGE,
			GameManager.get_item_count(Enums.Item.BATTERY) if GameManager else 0
		]
		sanity_label.text = "Sanity: %d" % player.sanity

	if GameManager != null:
		quota_label.text = "Quota: %d/%d" % [GameManager.ghosts_captured_this_level, GameManager.quota_this_level]