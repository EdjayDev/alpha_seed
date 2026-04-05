extends CharacterBody2D
class_name Player

@onready var player_sprite: Sprite2D = $player_sprite

const SPEED = 100.0
var animation_direction : String = "down"
var last_animation : String = ""
var state : String = "idle"

@onready var player_animation: AnimationPlayer = $player_animation

var is_in_cutscene : bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("player")
	var health = get_node_or_null("HealthComponent")
	if health:
		health.health_depleted.connect(_on_died)
		health.health_changed.connect(_on_health_changed)

func _on_health_changed(_old: float, _new: float) -> void:
	# Flash effect
	var tween = create_tween()
	tween.tween_property(player_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.1)

func _on_died() -> void:
	print("Player died!")
	# Simple restart for now
	get_tree().reload_current_scene()

func _physics_process(_delta: float) -> void:
	if is_in_cutscene:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if Input.is_action_just_pressed("Attack") and state != "attack":
		attack()
	
	if state == "attack":
		return

	var direction := Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
	if not direction:
		direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	
	if direction != Vector2.ZERO:
		state = "walk"
		if abs(direction.x) > abs(direction.y):
			animation_direction = "side"
			player_sprite.scale.x = -1.0 if direction.x > 0 else 1.0
		else:
			animation_direction = "down" if direction.y > 0 else "up"
		velocity = direction.normalized() * SPEED
	else:
		state = "idle"
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	update_animation()
	move_and_slide()

func update_animation()->void:
	if state == "attack": return
	var current_animation = state + "_" + animation_direction
	if current_animation != last_animation:
		player_animation.play(current_animation)
		last_animation = current_animation

func attack() -> void:
	state = "attack"
	player_animation.play("attack")
	await player_animation.animation_finished
	state = "idle"
	last_animation = "" # Force update

func deal_damage() -> void:
	# Called by animation track
	var attack_pos = global_position
	if animation_direction == "side":
		attack_pos += Vector2(12 * player_sprite.scale.x * -1, 0)
	elif animation_direction == "down":
		attack_pos += Vector2(0, 12)
	elif animation_direction == "up":
		attack_pos += Vector2(0, -12)

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if global_position.distance_to(enemy.global_position) < 20.0:
			var health = enemy.get_node_or_null("HealthComponent")
			if health:
				health.damage(25)
