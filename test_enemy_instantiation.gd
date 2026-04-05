extends Node

func test_enemy_instantiation():
	var enemy_scene = load("res://enemy/enemy.tscn")
	assert(enemy_scene != null, "Enemy scene should be loadable")
	var enemy = enemy_scene.instantiate()
	assert(enemy != null, "Enemy should be instantiable")
	assert(enemy.get_node("Sprite2D") != null, "Enemy should have a Sprite2D")
	assert(enemy.get_node("CollisionShape2D") != null, "Enemy should have a CollisionShape2D")
	assert(enemy.get_node("StateMachine") != null, "Enemy should have a StateMachine")
	assert(enemy.get_node("StateMachine/Idle") != null, "Enemy should have an Idle state")
	assert(enemy.get_node("StateMachine/Chase") != null, "Enemy should have a Chase state")
	assert(enemy.get_node("StateMachine/Attack") != null, "Enemy should have an Attack state")
	enemy.queue_free()
	print("Enemy instantiation test passed!")
