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
	if enemy.animation_player:
		enemy.animation_player.play("attack")
	
	# Small delay to sync with animation "impact"
	await enemy.get_tree().create_timer(0.15).timeout
	
	if not enemy or not enemy.player:
		return
		
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	if distance <= enemy.attack_range + 2.0: # Small buffer for movement during attack animation
		var health = enemy.player.get_node_or_null("HealthComponent")
		if health:
			health.damage(enemy.damage)
			print("Enemy hit player for ", enemy.damage, " damage!")
