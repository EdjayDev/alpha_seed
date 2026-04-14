class_name EnemyChaseState
extends State

@export var enemy: Enemy
var caution_range: float = 30.0

func physics_update(_delta: float) -> void:
	if enemy.is_in_cutscene:
		enemy.velocity = Vector2.ZERO
		return

	if not enemy.player:
		transitioned.emit("idle")
		return
	
	var distance = enemy.global_position.distance_to(enemy.player.global_position)
	
	if distance <= enemy.attack_range:
		transitioned.emit("attack")
		return
	
	# Pathfinding using breadcrumbs OR player directly
	var space_state = enemy.get_world_2d().direct_space_state
	var target_pos = BreadcrumbManager.get_next_target(
		enemy.global_position, 
		enemy.player.global_position, 
		space_state, 
		1 | 8 # Environment | Props
	)

	# Context steering for navigation
	var direction = enemy.get_steering_direction(target_pos)
	
	# "Be careful when near player"
	var current_speed = enemy.speed
	if distance < caution_range:
		# Slow down and prepare for attack
		current_speed *= 0.6
		
		# If very close but not yet attacking, maybe steer a bit to the side?
		# For simplicity, let's just slow down to show "caution".
	
	enemy.velocity = direction * current_speed
	
	if enemy.animation_player:
		var anim_dir = (enemy.player.global_position - enemy.global_position).normalized()
		enemy.play_directional_animation("walk", anim_dir)
