extends CharacterBody2D
class_name Player

@onready var player_sprite: Sprite2D = $player_sprite

const SPEED = 100.0
var animation_direction : String = "down"
var last_animation : String = ""
var state : String = "idle"

@onready var player_animation: AnimationPlayer = $player_animation

func _ready() -> void:
	add_to_group("player")
	var health = get_node_or_null("HealthComponent")
	if health:
		health.health_depleted.connect(_on_died)

func _on_died() -> void:
	print("Player died!")
	# Add game over logic here
	# get_tree().reload_current_scene()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Attack"):
		attack()
	
	var game : Main_Game = get_tree().get_root().get_node_or_null("Game")
	var direction := Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
	if not direction:
		direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	if game:
		if game.input_locked:
			direction = Vector2.ZERO
		if game.in_cutscene:
			return
	if direction != Vector2.ZERO:
		state = "walk"
		if abs(direction.x) > abs(direction.y):
			animation_direction = "side"
			if direction.x > 0:
				player_sprite.scale.x = -1
			else:
				player_sprite.scale.x = 1.0 
		else:
			if direction.y > 0:
				animation_direction = "down"
			else:
				animation_direction = "up"
		velocity = direction.normalized() * SPEED
	else:
		state = "idle"
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	update_animation()
	move_and_slide()

func update_animation()->void:
	var current_animation = state + "_" + animation_direction
	if current_animation != last_animation:
		player_animation.play(state + "_" + animation_direction)
		last_animation = current_animation

func attack() -> void:
	print("Player attacking!")
	# Simple proximity check for attacking
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if global_position.distance_to(enemy.global_position) < 40.0:
			var health = enemy.get_node_or_null("HealthComponent")
			if health:
				health.damage(25)
				print("Hit enemy for 25 damage!")
