class_name Ghost extends CharacterBody2D

@export var activation_radius: float = 60.0
@export var speed: float = 10.0

var player: CharacterBody2D

func _ready():
	pass

func _physics_process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		print("Player found:", player)
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > activation_radius:
		velocity = Vector2.ZERO
		return

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed

	move_and_slide()

func _draw():
	draw_circle(Vector2.ZERO, activation_radius, Color(1, 0, 0, 0.35)) 

func _process(delta):
	queue_redraw()
