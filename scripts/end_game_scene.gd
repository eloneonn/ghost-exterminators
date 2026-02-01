extends MarginContainer

@onready var stats_label: Label = %StatsLabel
@onready var main_menu_btn: Button = %ReturnBtn

@onready var end_game_text: Label = %EndGameText
@onready var end_game_description: Label = %EndGameDesc

func _ready() -> void:
    match GameManager.game_ending:
        Enums.GameEnding.INSANITY:
            end_game_text.text = "You went insane..."
            end_game_description.text = "The ghosts took over your mind and you lost your sanity."
        Enums.GameEnding.BANKRUPTCY:
            end_game_text.text = "You were fired..."
            end_game_description.text = "You violated your employment contract by causing too much damage."

    main_menu_btn.pressed.connect(_on_main_menu_btn_pressed)
    stats_label.text = (
        "\nStatistics: \n\n"
        + "Nights survived: " + str(GameManager.level) + "\n"
        + "Ghosts captured: " + str(GameManager.ghosts_captured) + "\n"
        + "Objects destroyed: " + str(GameManager.props_destroyed) + "\n"
        + "Total earnings: " + str(GameManager.total_earnings) + " coins\n"
        + "Total expenses: " + str(GameManager.total_expenses) + " coins\n"
        + "Total time spent in the masion: " + str(int(GameManager.total_time)) + " seconds"
    )

func _on_main_menu_btn_pressed() -> void:
    GameManager.reset_game()
    GameManager.goto_scene("res://scenes/main_menu.tscn")