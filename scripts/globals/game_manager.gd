extends Node

# Properties

var level: int = 0;
var money: int = 0;
var inventory: Array[Enums.Item] = [];

# Statistics

var ghosts_captured: int = 0;
var props_destroyed: int = 0;
var total_time: float = 0.0;
var total_earnings: int = 0;
var total_expenses: int = 0;

func _ready() -> void:
    money = Constants.STARTING_MONEY;
    for item in Constants.STARTING_INVENTORY:
        inventory.append(item)

func next_level() -> void:
    level += 1

func add_money(amount: int) -> void:
    total_earnings += amount;
    money += amount

func remove_money(amount: int) -> void:
    total_expenses += amount;
    money -= amount

func get_money() -> int:
    return money

func get_inventory() -> Array[Enums.Item]:
    return inventory

func add_item(item: Enums.Item) -> void:
    inventory.append(item)

func remove_item(item: Enums.Item) -> void:
    inventory.erase(item)

func has_item(item: Enums.Item) -> bool:
    return inventory.has(item)

func get_item_count(item: Enums.Item) -> int:
    return inventory.count(item)

func capture_ghost() -> void:
    ghosts_captured += 1

func destroy_prop() -> void:
    props_destroyed += 1

func end_game() -> void:
    get_tree().change_scene_to_file("res://scenes/end_game_scene.tscn")