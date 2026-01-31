extends MarginContainer

@onready var stats_label: Label = %StatsLabel

func _ready() -> void:
    stats_label.text = (
        "Stats: \n"
        + "Ghosts captured: " + str(GameManager.ghosts_captured) + "\n"
        + "Props destroyed: " + str(GameManager.props_destroyed) + "\n"
        + "Total earnings: " + str(GameManager.total_earnings) + "\n"
        + "Total expenses: " + str(GameManager.total_expenses) + "\n"
        + "Total time spent in thes theater: " + str(GameManager.total_time)
    )
    