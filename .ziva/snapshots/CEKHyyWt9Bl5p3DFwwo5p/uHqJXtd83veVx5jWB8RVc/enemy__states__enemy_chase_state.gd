class_name EnemyChaseState
extends State

@export var enemy: Enemy

func physics_update(_delta: float) -> void:
	if not enemy.player:
		transitioned.emit("idle")
		return
	
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	
	if distance <= enemy.attack_range:
		transitioned.emit("attack")
		return
	
	var direction = (enemy.player.global_position - enemy.global_position).normalized()
	enemy.velocity = direction * enemy.speed
	
	if enemy.animation_player:
		enemy.animation_player.play("walk")
	
	# Flip sprite
	if direction.x > 0:
		enemy.sprite.flip_h = true
	else:
		enemy.sprite.flip_h = false
