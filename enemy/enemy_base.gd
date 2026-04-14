class_name Enemy
extends CharacterBody2D

@export var speed: float = 60.0
@export var attack_range: float = 14.0
@export var damage: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar
@onready var hit_particles: CPUParticles2D = $HitParticles

var player: Player
var is_in_cutscene : bool = false

# Context steering properties
var num_rays: int = 16
var ray_directions: Array[Vector2] = []
var interest: Array[float] = []
var danger: Array[float] = []
var look_ahead: float = 64.0

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("enemy")
	
	# Initialize ray directions
	for i in range(num_rays):
		var angle = i * 2 * PI / num_rays
		ray_directions.append(Vector2.RIGHT.rotated(angle))
	interest.resize(num_rays)
	danger.resize(num_rays)
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().get_root().find_child("Player", true, false) as Player
	
	if health_component:
		health_component.health_depleted.connect(_on_died)
		health_component.health_changed.connect(_on_health_changed)
		if health_bar:
			health_bar.max_value = health_component.max_health
			health_bar.value = health_component.health

func _on_health_changed(_old_health: float, new_health: float) -> void:
	if health_bar:
		health_bar.value = new_health
		health_bar.visible = true
	
	if hit_particles:
		hit_particles.restart()
		hit_particles.emitting = true
	
	# Flash effect
	var tween = create_tween()
	sprite.modulate = Color.WHITE
	tween.tween_property(sprite, "modulate", Color(0.8, 0.4, 1.0), 0.1) # Back to purple
	
	# Knockback
	if player:
		var knock_dir = (global_position - player.global_position).normalized()
		velocity = knock_dir * 100.0
		var v_tween = create_tween()
		v_tween.tween_property(self, "velocity", Vector2.ZERO, 0.2)

func play_directional_animation(anim_base: String, dir: Vector2) -> void:
	var suffix = "_down"
	if abs(dir.x) > abs(dir.y):
		suffix = "_side"
		if sprite:
			sprite.scale.x = -1.0 if dir.x > 0 else 1.0
	elif dir.y < 0:
		suffix = "_up"
	else:
		suffix = "_down"
	
	if animation_player:
		animation_player.play(anim_base + suffix)

func _on_died() -> void:
	if state_machine:
		state_machine.on_child_transition("death")
	else:
		# Fallback if no state machine
		if animation_player:
			animation_player.play("death")
			await animation_player.animation_finished
		queue_free()

func deal_damage() -> void:
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range + 5.0:
		var health = player.get_node_or_null("HealthComponent")
		if health:
			health.damage(damage)

func get_steering_direction(target_pos: Vector2) -> Vector2:
	set_interest(target_pos)
	set_danger()
	
	# Eliminate danger from interest
	for i in range(num_rays):
		# We can use a smoother subtraction for more organic movement
		interest[i] = max(0, interest[i] - danger[i])
	
	# Choose direction
	var chosen_dir = Vector2.ZERO
	for i in range(num_rays):
		chosen_dir += ray_directions[i] * interest[i]
	
	if chosen_dir == Vector2.ZERO:
		# If stuck, try to move away from the strongest danger, 
		# but add a side-ways component to "slide"
		var max_danger_idx = -1
		var max_danger = 0.0
		for i in range(num_rays):
			if danger[i] > max_danger:
				max_danger = danger[i]
				max_danger_idx = i
		
		if max_danger_idx != -1:
			var danger_dir = ray_directions[max_danger_idx]
			# Rotate 90 degrees to find a "side" to slide along
			chosen_dir = danger_dir.rotated(PI / 2)
	
	return chosen_dir.normalized()

func set_interest(target_pos: Vector2) -> void:
	var target_dir = (target_pos - global_position).normalized()
	for i in range(num_rays):
		var d = ray_directions[i].dot(target_dir)
		interest[i] = max(0, d)

func set_danger() -> void:
	var space_state = get_world_2d().direct_space_state
	for i in range(num_rays):
		# Look ahead for environment and props (Layers 1 and 4)
		var ray_pos = global_position + ray_directions[i] * look_ahead
		var query = PhysicsRayQueryParameters2D.create(global_position, ray_pos, 1 | 8) # Environment | Props
		query.exclude = [get_rid()]
		
		var result = space_state.intersect_ray(query)
		danger[i] = 0.0
		if result:
			var distance = global_position.distance_to(result.position)
			# Stronger avoidance as we get closer
			danger[i] = pow(1.0 - (distance / look_ahead), 0.5)
		
		# Side rays (whiskers) check to help with narrow passages and corners
		# If a ray hits something, we also increase danger for its neighbors
		# but with a decay.
	
	# Post-process danger to "spread" it slightly, helping the AI avoid clipping corners
	var new_danger = danger.duplicate()
	for i in range(num_rays):
		var prev = (i - 1 + num_rays) % num_rays
		var next = (i + 1) % num_rays
		new_danger[i] = max(danger[i], max(danger[prev] * 0.5, danger[next] * 0.5))
	danger = new_danger

	# Also avoid other enemies (Layer 3) with a shorter distance
	for i in range(num_rays):
		var enemy_ray_pos = global_position + ray_directions[i] * 32.0
		var enemy_query = PhysicsRayQueryParameters2D.create(global_position, enemy_ray_pos, 4) # Enemies
		enemy_query.exclude = [get_rid()]
		var enemy_result = space_state.intersect_ray(enemy_query)
		if enemy_result:
			var distance = global_position.distance_to(enemy_result.position)
			danger[i] = max(danger[i], 0.8 * (1.0 - (distance / 32.0)))

func _physics_process(_delta: float) -> void:
	if is_in_cutscene:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	move_and_slide()
