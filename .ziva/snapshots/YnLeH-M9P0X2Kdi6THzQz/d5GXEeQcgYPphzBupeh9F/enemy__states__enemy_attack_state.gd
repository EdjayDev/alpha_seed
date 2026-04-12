class_name EnemyAttackState
extends State

@export var enemy: Enemy
@export var attack_cooldown: float = 1.0

var is_attacking: bool = false

func enter() -> void:
	timer = attack_cooldown # Start ready to attack or wait? Let's start ready.
	enemy.velocity = Vector2.ZERO
	is_attacking = false

func exit() -> void:
	is_attacking = false

func update(delta: float) -> void:
	if enemy.is_in_cutscene:
		enemy.velocity = Vector2.ZERO
		return

	timer += delta
	enemy.velocity = Vector2.ZERO
	
	if not enemy.player:
		transitioned.emit("idle")
		return
	
	var dir = (enemy.player.global_position - enemy.global_position).normalized()
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	
	if not is_attacking:
		if distance > enemy.attack_range + 5.0: # Add buffer
			transitioned.emit("chase")
			return
		
		if timer >= attack_cooldown:
			perform_attack(dir)
			timer = 0.0
		else:
			# Stay in idle pose while waiting
			enemy.play_directional_animation("idle", dir)

func perform_attack(dir: Vector2) -> void:
	is_attacking = true
	enemy.play_directional_animation("attack", dir)
	
	if enemy.animation_player:
		# Use a signal with a one-shot connection or just wait
		# await is fine if we check if we are still in this state
		await enemy.animation_player.animation_finished
	
	is_attacking = false
