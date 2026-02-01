extends MarginContainer

@onready var stats_label: Label = %StatsLabel
@onready var main_menu_btn: Button = %ReturnBtn

func _ready() -> void:
    main_menu_btn.pressed.connect(_on_main_menu_btn_pressed)
    stats_label.text = (
        "\nStatistics: \n\n"
        + "Nights survived: " + str(GameManager.level) + "\n"
        + "Ghosts captured: " + str(GameManager.ghosts_captured) + "\n"
        + "Objects destroyed: " + str(GameManager.props_destroyed) + "\n"
        + "Total earnings: " + str(GameManager.total_earnings) + " coins\n"
        + "Total expenses: " + str(GameManager.total_expenses) + " coins\n"
        + "Total time spent in the theater: " + str(GameManager.total_time) + " seconds"
    )

func _on_main_menu_btn_pressed() -> void:
    GameManager.reset_game()
    GameManager.goto_scene("res://scenes/main_menu.tscn")