class_name Enemy
extends CharacterBody2D

@export var speed: float = 60.0
@export var attack_range: float = 14.0
@export var damage: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: Node = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar
@onready var hit_particles: CPUParticles2D = $HitParticles

var player: Player
var is_in_cutscene : bool = false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("enemy")
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
		# Simple knockback decay over time in physics process is usually better, but for polish:
		var v_tween = create_tween()
		v_tween.tween_property(self, "velocity", Vector2.ZERO, 0.2)

func play_directional_animation(anim_base: String, dir: Vector2) -> void:
	var suffix = "_down"
	if abs(dir.x) > abs(dir.y):
		suffix = "_side"
		if sprite:
			sprite.flip_h = (dir.x > 0)
	elif dir.y < 0:
		suffix = "_up"
	else:
		suffix = "_down"
	
	if animation_player:
		animation_player.play(anim_base + suffix)

func _on_died() -> void:
	# Death animation
	if animation_player:
		animation_player.play("death")
		await animation_player.animation_finished
	queue_free()

func deal_damage() -> void:
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range + 5.0: # Small buffer
		var health = player.get_node_or_null("HealthComponent")
		if health:
			health.damage(damage)
			print("Enemy hit player for ", damage, " damage!")

func _physics_process(_delta: float) -> void:
	if is_in_cutscene:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	move_and_slide()
