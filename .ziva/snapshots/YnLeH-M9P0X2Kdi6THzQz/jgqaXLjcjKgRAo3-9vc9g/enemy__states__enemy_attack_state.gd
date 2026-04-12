class_name EnemyAttackState
extends State

@export var enemy: Enemy
@export var attack_cooldown: float = 1.0

var timer: float = 0.0

func enter() -> void:
	timer = 0.0
	enemy.velocity = Vector2.ZERO
	attack()

func exit() -> void:
	pass

func update(delta: float) -> void:
	if enemy.is_in_cutscene:
		enemy.velocity = Vector2.ZERO
		return

	timer += delta
	enemy.velocity = Vector2.ZERO
	
	if not enemy.player:
		transitioned.emit("idle")
		return
	
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	
	if distance > enemy.attack_range:
		transitioned.emit("chase")
	elif timer >= attack_cooldown:
		attack()
		timer = 0.0

func attack() -> void:
	if not enemy or not enemy.player:
		return
	
	var dir = (enemy.player.global_position - enemy.global_position).normalized()
	enemy.play_directional_animation("attack", dir)
	
	# Wait for animation to finish
	if enemy.animation_player:
		await enemy.animation_player.animation_finished
	else:
		await enemy.get_tree().create_timer(0.4).timeout
