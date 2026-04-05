class_name EnemyIdleState
extends State

@export var enemy: Enemy
@export var detection_range: float = 150.0

func update(_delta: float) -> void:
	if enemy.animation_player:
		enemy.animation_player.play("idle")
	
	if not enemy.player:
		return
	
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	if distance < detection_range:
		transitioned.emit("chase")
