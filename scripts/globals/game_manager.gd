extends Node

signal quota_reached(quota: int)

const LOADING_SCREEN_PATH := "res://scenes/loading_screen.tscn"

# Scene transition
var pending_scene_path: String = ""

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

var quota_this_level: int = Constants.STARTING_QUOTA;
var ghosts_captured_this_level: int = 0;
var money_earned_this_level: int = 0;


func _ready() -> void:
    money = Constants.STARTING_MONEY;
    for item in Constants.STARTING_INVENTORY:
        inventory.append(item)

func next_level() -> void:
    level += 1
    quota_this_level = Constants.STARTING_QUOTA + level;
    ghosts_captured_this_level = 0;
    money_earned_this_level = 0;

func get_items_string() -> String:
    return "\n".join(inventory.map(func(item: Enums.Item) -> String:
        return Constants.ITEM_NAMES.get(item, Enums.Item.keys()[item])
    ))

func add_money(amount: int) -> void:
    total_earnings += amount;
    money += amount
    money_earned_this_level += amount

func remove_money(amount: int) -> void:
    total_expenses += amount;
    money -= amount
    money_earned_this_level -= amount

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

func capture_ghost(value: int) -> void:
    ghosts_captured += 1
    ghosts_captured_this_level += 1

    if (ghosts_captured_this_level >= quota_this_level):
        quota_reached.emit(quota_this_level)
    
    add_money(value)

func destroy_prop(value: int) -> void:
    props_destroyed += 1
    remove_money(value)

func end_game(_ending: Enums.GameEnding) -> void:
    get_tree().change_scene_to_file("res://scenes/end_game_scene.tscn")

func goto_scene(scene_path: String) -> void:
    pending_scene_path = scene_path
    get_tree().change_scene_to_file(LOADING_SCREEN_PATH)

func reset_game() -> void:
    level = 0;
    money = Constants.STARTING_MONEY;
    inventory = Constants.STARTING_INVENTORY;
    ghosts_captured = 0;
    ghosts_captured_this_level = 0;
    money_earned_this_level = 0;
    props_destroyed = 0;
    total_time = 0.0;
    total_earnings = 0;
    total_expenses = 0;
    quota_this_level = Constants.STARTING_QUOTA;