@tool
class_name Prop extends CharacterBody2D

@export var activation_radius: float = 60.0
@export var speed: float = 10.0
@export var health: int = 100;
@export var ghost: bool = false;
## Monetary value of the prop
@export var value: int = 100;
@export var texture: Texture2D = null;
## Prop is frozen if the player is shining a flashlight on it
var frozen: bool = false;

@onready var sprite: Sprite2D = $Sprite2D

var player: CharacterBody2D

func _ready():
	if texture != null:
		sprite.texture = texture;
	pass

func _physics_process(_delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return

	var distance = global_position.distance_to(player.global_position)

	if ghost && !frozen && distance <= activation_radius:
		follow_player()
	else:
		velocity = Vector2.ZERO

func follow_player() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed

	move_and_slide()

func take_damage(damage: int) -> void:
	print("Prop took damage: ", damage)
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	if ghost:
		GameManager.capture_ghost(self.value)
	else:
		GameManager.destroy_prop(self.value)

	queue_free()
