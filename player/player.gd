extends CharacterBody2D
class_name Player

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

@onready var player_animation: AnimationPlayer = $player_animation

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var game : Main_Game = get_tree().get_root().get_node("Game")
	if game.input_locked:
		return
	var direction := Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
	if direction:
		player_animation.play("walk")
		velocity = direction.normalized() * SPEED
	else:
		player_animation.play("idle")
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	move_and_slide()
