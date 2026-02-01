extends Node2D

const MUSIC_CALM := "res://music/theater_calm.wav"
const MUSIC_AGGRESSIVE := "res://music/theater_aggressive.wav"
const AGGRESSIVE_HOLD_TIME := 5.0
const AGGRESSIVE_FADE_DURATION := 2.0
const MUTED_DB := -80.0

@onready var door: Node = %Door
@onready var pause_menu: CanvasLayer = %PauseMenu

@export var ghost_count: int = GameManager.quota_this_level * randi_range(1, 3)       # how many props become ghosts
@export var randomize_behaviour: bool = true

var _music_calm: AudioStreamPlayer
var _music_aggressive: AudioStreamPlayer
var _aggressive_hold_timer: Timer
var _volume_tween: Tween

func _ready() -> void:
	_setup_music()
	_connect_jumpscare_signals()

	print(ghost_count, " ghosts will be assigned in this level.")
	door.set_prompt("Enter the Safehouse Scene (Press E)")
	door.interacted.connect(_on_door_triggered)

	if (GameManager.level == 1):
		var player: Player = get_tree().get_first_node_in_group("player")
		player.show_thought("The ghosts are hiding in the props, better start searching...", 5.0)
		player.show_thought("I should use my GhostRay (left click) to catch them", 20.0)
		player.show_thought("Hmm, I swear that thing moved...", 35.0)

	_assign_random_ghosts()

func _setup_music() -> void:
	_music_calm = AudioStreamPlayer.new()
	_music_calm.bus = "Music"
	_music_calm.volume_db = 0.0
	add_child(_music_calm)

	_music_aggressive = AudioStreamPlayer.new()
	_music_aggressive.bus = "Music"
	_music_aggressive.volume_db = MUTED_DB
	add_child(_music_aggressive)

	var calm_stream: AudioStreamWAV = load(MUSIC_CALM) as AudioStreamWAV
	if calm_stream:
		calm_stream = calm_stream.duplicate()
		calm_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_music_calm.stream = calm_stream
		_music_calm.play()

	var aggressive_stream: AudioStreamWAV = load(MUSIC_AGGRESSIVE) as AudioStreamWAV
	if aggressive_stream:
		aggressive_stream = aggressive_stream.duplicate()
		aggressive_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		_music_aggressive.stream = aggressive_stream
		_music_aggressive.play()

	_aggressive_hold_timer = Timer.new()
	_aggressive_hold_timer.one_shot = true
	_aggressive_hold_timer.timeout.connect(_on_aggressive_hold_timeout)
	add_child(_aggressive_hold_timer)

func _connect_jumpscare_signals() -> void:
	var props: Array = get_tree().get_nodes_in_group("props")
	for node in props:
		if node is Prop:
			(node as Prop).jumpscared.connect(_on_jumpscared)

func _on_jumpscared() -> void:
	if _volume_tween and _volume_tween.is_valid():
		_volume_tween.kill()

	_volume_tween = create_tween()
	_volume_tween.tween_property(_music_aggressive, "volume_db", 0.0, 0.3)

	_aggressive_hold_timer.start(AGGRESSIVE_HOLD_TIME)

func _on_aggressive_hold_timeout() -> void:
	if _volume_tween and _volume_tween.is_valid():
		_volume_tween.kill()

	_volume_tween = create_tween()
	_volume_tween.tween_property(_music_aggressive, "volume_db", MUTED_DB, AGGRESSIVE_FADE_DURATION)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Engine.time_scale = 0.0 if Engine.time_scale == 1.0 else 1.0
		pause_menu.visible = !pause_menu.visible

func _on_door_triggered() -> void:
	if (GameManager.ghosts_captured_this_level < GameManager.quota_this_level):
		var player: Player = get_tree().get_first_node_in_group("player")
		player.show_thought("I need to capture at least " + str(GameManager.quota_this_level) + " ghosts to tonight...", 0.0)
		return
	
	get_tree().change_scene_to_file("res://scenes/safehouse_scene.tscn")

func _assign_random_ghosts() -> void:
	print("Assigning random ghosts...")
	# Get all props in the scene
	var props: Array = get_tree().get_nodes_in_group("props")

	# Safety: only keep actual Prop nodes
	props = props.filter(func(n): return n is Prop)
	print("Found", props, "props in the scene.")
	if props.is_empty():
		push_warning("No props found (group 'props' empty).")
		return

	# Clamp so we don't ask more ghosts than props
	var count: int = clamp(ghost_count, 0, props.size())
	print(count, "ghosts to assign out of", props.size(), "props.")
	# Randomize selection
	randomize()
	props.shuffle()

	for p: Prop in props:
		p.ghost = false

	for i in range(count):
		var p: Prop = props[i]
		p.ghost = true

		if randomize_behaviour:
			print(Prop.GhostBehaviour.values().pick_random())
			p.ghost_behaviour = Prop.GhostBehaviour.values().pick_random()

		print("Ghost prop:", p.name, "behaviour:", p.ghost_behaviour)
