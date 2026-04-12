class_name EnemyDeathState
extends State

@export var enemy: Enemy

func enter() -> void:
	enemy.velocity = Vector2.ZERO
	if enemy.animation_player:
		enemy.animation_player.play("death")
		await enemy.animation_player.animation_finished
	# We don't queue_free immediately so the body stays for a bit or just disappear after anim
	enemy.queue_free()

func physics_update(_delta: float) -> void:
	enemy.velocity = Vector2.ZERO
