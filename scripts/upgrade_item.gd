class_name UpgradeItem extends Control

signal purchased(item: Enums.Item)

@export var item: Enums.Item
@export var cost: int
@export var description: String
# @export var icon: Texture2D

@onready var item_name: Label = %ItemName
@onready var cost_label: Label = %CostLabel
@onready var description_label: Label = %DescriptionLabel
#@onready var icon_sprite: Sprite2D = %IconSprite
@onready var buy_button: Button = %BuyBtn

func _on_buy_button_pressed() -> void:
	if GameManager.get_money() >= cost:
		GameManager.remove_money(cost)
		GameManager.add_item(item)
		purchased.emit(item)

		if item != Enums.Item.BATTERY:
			buy_button.disabled = true
			buy_button.text = "Purchased"

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)	
	item_name.text = Constants.ITEM_NAMES.get(item, Enums.Item.keys()[item])
	cost_label.text = str(cost)
	description_label.text = description
	#icon_sprite.texture = icon
	if item != Enums.Item.BATTERY and GameManager.has_item(item):
		buy_button.disabled = true
		buy_button.text = "Purchased"

func _process(_delta: float) -> void:
	if item != Enums.Item.BATTERY and GameManager.has_item(item):
		buy_button.disabled = true
		buy_button.text = "Purchased"
	elif GameManager.get_money() >= cost:
		buy_button.disabled = false
	else:
		buy_button.disabled = true
