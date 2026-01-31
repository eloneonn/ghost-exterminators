extends Node2D

@onready var door: Node = %Door

@export var ghost_count: int = 3           # how many props become ghosts
@export var randomize_behaviour: bool = true

func _ready() -> void:
	door.set_prompt("Enter the Safehouse Scene (Press E)")
	door.interacted.connect(_on_door_triggered)

	_assign_random_ghosts()

func _on_door_triggered() -> void:
	print("Transitioning to safehouse scene.")
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