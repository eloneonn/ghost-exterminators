extends Node2D

@onready var door: Node = %Door
@onready var upgrade_desk: Node = %UpgradeDesk
@onready var upgrade_ui: Node = %UpgradeUI
#@onready var add_money_button: Button = %GetMoneyButton

@onready var money_label: Label = %MoneyLabel
@onready var items_list: Label = %ItemsList
@onready var upgrade_items_container: VBoxContainer = %UpgradeItems

@onready var tutorial_text: RichTextLabel = %TutorialText
@onready var tutorial_door: RichTextLabel = %TutorialDoor
@onready var stats_text: RichTextLabel = %StatsText

func _ready() -> void:
	door.set_prompt("Press E")
	door.interacted.connect(_on_door_triggered)
	upgrade_desk.set_prompt("Press E")
	upgrade_desk.interacted.connect(_on_upgrade_desk_interacted)
	#add_money_button.pressed.connect(_on_add_money_button_pressed)
	_connect_upgrade_items()
	
	if GameManager.level == 0:
		tutorial_text.visible = true;
		tutorial_door.visible = true;
		stats_text.visible = false;
	else:
		stats_text.text = "Night " + str(GameManager.level) + " stats:\n\nGhosts captured: " + str(GameManager.ghosts_captured_this_level) + "\n\nMoney earned: " + str(GameManager.money_earned_this_level) + "\n\nTotal money: " + str(GameManager.get_money());
		tutorial_text.visible = false;
		tutorial_door.visible = false;
		stats_text.visible = true;

	var player: Player = get_tree().get_first_node_in_group("player")
	if (GameManager.level == 0):
		player.show_thought("All right, let's get this show on the road!", 0.0)
	if (GameManager.level == 1):
		player.show_thought("That was intense... I better upgrade my gear for tomorrow.", 0.0)
	if (GameManager.level == 2):
		player.show_thought("Phew, that was a close one... I need to get some rest.", 0.0)
	if (GameManager.level == 3):
		player.show_thought("I'm getting the hang of this! Another day, another shift of ghost extermination.", 0.0)
	if (GameManager.level >= 4):
		player.show_thought("I can't think of anyting else to write here, thanks so much for playing!", 0.0)

func _process(_delta: float) -> void:
	items_list.text = GameManager.get_items_string()
	money_label.text = "Money: " + str(GameManager.get_money())

func _on_door_triggered() -> void:
	GameManager.next_level()
	print("Starting level" + str(GameManager.level))
	get_tree().change_scene_to_file("res://scenes/level_scene.tscn")

func _on_add_money_button_pressed() -> void:
	GameManager.add_money(100)
	print("Added money!")
	print("Current money:" + str(GameManager.get_money()))
func _on_upgrade_desk_interacted() -> void:
	if upgrade_ui.visible:
		upgrade_ui.visible = false
	else:
		upgrade_ui.visible = true
	print("Upgrade Desk interacted with.")

func _connect_upgrade_items() -> void:
	var upgrade_items := upgrade_ui.find_children("*", "UpgradeItem", true, false)
	for child in upgrade_items:
		if child is UpgradeItem:
			_ensure_upgrade_item_id(child)
			if not child.purchased.is_connected(_on_upgrade_purchased):
				child.purchased.connect(_on_upgrade_purchased)

func _ensure_upgrade_item_id(item_node: UpgradeItem) -> void:
	var name_to_item := {
		"UpgradeItemGunDamage": Enums.Item.GUN_DAMAGE,
		"UpgradeItemGunRange": Enums.Item.GUN_RANGE,
		"UpgradeItemGunCooling": Enums.Item.GUN_COOLING,
		"UpgradeItemPlayerSpeed": Enums.Item.PLAYER_SPEED,
		"UpgradeItemPlayerBattery": Enums.Item.PLAYER_BATTERY,
	}

	if name_to_item.has(item_node.name):
		item_node.item = name_to_item[item_node.name]

func _on_upgrade_purchased(_item: Enums.Item) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		player._apply_upgrades()
		# var ray := player.ghost_ray
		# if ray is GhostRay:
		# 	ray._apply_upgrades()
