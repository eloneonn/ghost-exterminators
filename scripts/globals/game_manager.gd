extends Node

var level: int = 0;
var money: int = 0;

func _ready() -> void:
    pass

func next_level() -> void:
    level += 1

func add_money(amount: int) -> void:
    money += amount

func remove_money(amount: int) -> void:
    money -= amount

func get_money() -> int:
    return money