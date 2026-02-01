extends CanvasLayer

@onready var battery_rect: TextureRect = %BatteryTexture
@onready var battery_label: Label = %BatteryLabel
@onready var quota_label: Label = %QuotaLabel
@onready var coin_label: Label = %CoinLabel

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") as Player

	if player != null:
		if player.battery_charge < Constants.BATTERY_MAX_CHARGE * 0.25:
			battery_rect.texture = preload("res://assets/battery/battery1.tres")
		elif player.battery_charge < Constants.BATTERY_MAX_CHARGE * 0.5:
			battery_rect.texture = preload("res://assets/battery/battery2.tres")
		elif player.battery_charge < Constants.BATTERY_MAX_CHARGE * 0.75:
			battery_rect.texture = preload("res://assets/battery/battery3.tres")
		else:
			battery_rect.texture = preload("res://assets/battery/battery4.tres")

	if GameManager != null:
		battery_label.text = str(GameManager.get_item_count(Enums.Item.BATTERY))
		quota_label.text = "%d/%d" % [GameManager.ghosts_captured_this_level, GameManager.quota_this_level]
		coin_label.text = str(GameManager.get_money())
