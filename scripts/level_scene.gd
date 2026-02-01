extends Node2D

const MUSIC_CALM := "res://music/theater_calm.wav"
const MUSIC_AGGRESSIVE := "res://music/theater_aggressive.wav"
const AGGRESSIVE_HOLD_TIME := 5.0
const AGGRESSIVE_FADE_DURATION := 2.0
const MUTED_DB := -80.0

@onready var door: Node = %Door
@onready var pause_menu: CanvasLayer = %PauseMenu

@export var randomize_behaviour: bool = true

var _music_calm: AudioStreamPlayer
var _music_aggressive: AudioStreamPlayer
var _aggressive_hold_timer: Timer
var _volume_tween: Tween

func _ready() -> void:
	_setup_music()
	_connect_jumpscare_signals()
	GameManager.start_timer()

	door.set_prompt("Enter the Safehouse Scene (Press E)")
	door.interacted.connect(_on_door_triggered)

	_show_level_dialogue(GameManager.level)

	_assign_random_ghosts()


func _show_level_dialogue(level: int) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	# Level-start dialogue progression: more confident and cocky over time.
	var lines := _get_level_lines(level)
	if lines.is_empty():
		return

	# Timing: early lines front-loaded. We also have a random extra punchline.
	var base_times := [5.0, 20.0, 35.0]
	for i in range(min(lines.size(), base_times.size())):
		player.show_thought(lines[i], base_times[i])

	# 55% chance to add a random horror-comedy stinger a bit later.
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if rng.randf() < 0.55:
		player.show_thought(_get_random_stinger(), 50.0)

func _get_level_lines(level: int) -> Array[String]:
	var by_level := {
		1: [
			"The ghosts are hiding in the props... better start searching.",
			"GhostRay (hold down left mouse click) should do the trick. Please don't explode.",
			"Hmm... I swear that thing moved."
		],
		2: [
			"Okay. Same deal: props are suspicious, hallways are worse.",
			"If I hear whispers behind me, I’m simply not turning around.",
			"This place has big 'don't split up' energy. So I won't."
		],
		3: [
			"All right... I'm not new anymore. I'm a professional.",
			"Ghosts: you get one jump-scare for free. After that, it's business.",
			"If a cursed mirror shows my doom, I'm charging it rent."
		],
		4: [
			"Night four. The haunted decor is starting to feel… predictable.",
			"If the lights flicker, that's just the ghosts applauding my work.",
			"Come on then. I'm basically the final boss now."
		]
	}

	var set: Array = by_level.get(level, [])
	var out: Array[String] = []
	for s in set:
		out.append(str(s))
	return out

func _get_random_stinger() -> String:
	var stingers: Array[String] = [
		"Rule #1: never say 'What could possibly go wrong?' out loud.",
		"If a creepy doll is in here, I'm leaving. Immediately.",
		"If I hear spooky piano music, I'm turning around. Not today.",
		"Somewhere a narrator is like: 'He was, in fact, not fine.'",
		"If a child giggles in the hallway. nope. Filing a complaint.",
		"If the door creaks open by itself, I'm creaking out of here.",
		"Why are there always candles? Is there an interior designer ghost?",
		"If I see a shadowy figure, I'm asking for its autograph.",
		"Note to self: never trust a ghost that offers to 'play a game.'",
		"If I find a Ouija board, I'm ghosting this job.",
		"Why do ghosts always haunt places with bad Wi-Fi?",
		"If I see a floating orb, I'm calling it 'Bob' and moving on",
		"Is it just me, or do haunted houses always smell like mold?",
		"If a ghost asks me to 'join them,' I'm declining the invitation.",
		"Why do ghosts always seem to prefer old, creaky furniture?",
		"If I hear footsteps behind me, I'm not looking back.",
		"Why is it that every haunted house has at least one creepy attic?",
		"If a ghost offers me a deal, I'm reading the fine print carefully.",
		"Why do ghosts always seem to appear in the most inconvenient places?",
		"If I see a ghostly figure in a mirror, I'm not making eye contact",
		"Some people spend their time at gamejams. I spend mine evicting ghosts."
		]

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return stingers[rng.randi_range(0, stingers.size() - 1)]

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
		var is_pausing := Engine.time_scale == 1.0
		Engine.time_scale = 0.0 if is_pausing else 1.0
		pause_menu.visible = is_pausing
		if is_pausing:
			GameManager.pause_timer()
		else:
			GameManager.start_timer()

func _on_door_triggered() -> void:
	if (GameManager.ghosts_captured_this_level < GameManager.quota_this_level):
		var player: Player = get_tree().get_first_node_in_group("player")
		player.show_thought("I need to capture at least " + str(GameManager.quota_this_level) + " ghosts to tonight...", 0.0)
		return

	if GameManager.get_money() < 0:
		GameManager.end_timer()
		GameManager.end_game(Enums.GameEnding.BANKRUPTCY);
		return
	
	GameManager.pause_timer()
	GameManager.goto_scene("res://scenes/safehouse_scene.tscn")

func _assign_random_ghosts() -> void:
	print("Assigning random ghosts...")
	# Get all props in the scene
	var props: Array = get_tree().get_nodes_in_group("props")

	# Safety: only keep actual Prop nodes
	props = props.filter(func(n): return n is Prop and n.excluded_from_ghosts == false)
	print("Found", props, "props in the scene.")
	if props.is_empty():
		push_warning("No props found (group 'props' empty).")
		return

	var ghost_count = clamp(173 * randf_range(0.15, 0.3), GameManager.quota_this_level * 1.5, 173);

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
