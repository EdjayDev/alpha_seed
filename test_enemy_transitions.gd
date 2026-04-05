extends Node

func test_enemy_state_transitions():
	var enemy_scene = load("res://enemy/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	
	var state_machine = enemy.get_node("StateMachine")
	var idle_state = state_machine.get_node("Idle")
	var chase_state = state_machine.get_node("Chase")
	var attack_state = state_machine.get_node("Attack")
	
	# Manually call _ready() for initialization
	enemy._ready()
	state_machine._ready()
	for child in state_machine.get_children():
		child._ready()
	
	# Initial state should be "idle"
	assert(state_machine.current_state == idle_state, "Initial state should be Idle")
	
	# Mock a player object
	var player = CharacterBody2D.new()
	player.name = "Player"
	player.add_to_group("player")
	# Instead of add_child to tree, we'll just manipulate position and detection
	player.global_position = Vector2(1000, 1000) # Far away
	
	# Test idle transition to chase
	player.global_position = enemy.global_position + Vector2(10, 10) # Close to enemy
	# Mock detection
	enemy.player = player
	state_machine._process(0.1)
	assert(state_machine.current_state == chase_state, "Enemy should transition to Chase when player is close")
	
	# Test chase transition to attack
	player.global_position = enemy.global_position + Vector2(5, 5) # Within attack range
	state_machine._process(0.1)
	assert(state_machine.current_state == attack_state, "Enemy should transition to Attack when player is in range")
	
	# Test attack transition back to chase
	player.global_position = enemy.global_position + Vector2(60, 60) # Out of attack range, but still in detection range
	state_machine._process(0.1)
	assert(state_machine.current_state == chase_state, "Enemy should transition back to Chase when player moves out of attack range")
	
	# Test chase transition back to idle
	enemy.player = null # Mock player lost
	state_machine._process(0.1)
	assert(state_machine.current_state == idle_state, "Enemy should transition back to Idle when player is gone")
	
	enemy.queue_free()
	player.queue_free()
	print("Enemy state transitions test passed!")
