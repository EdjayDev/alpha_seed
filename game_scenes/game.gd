extends Node2D
class_name Main_Game

@onready var label: Label = $animation_nodes/TitleLabel
@onready var game_anim_player: AnimationPlayer = $animation_nodes/game_anim_player
@onready var player: Player = $y_sort/Player
@onready var dialogue_ui: Control = $animation_nodes/DialogueUI
@onready var dialogue_label: Label = $animation_nodes/DialogueUI/Panel/Label

@onready var victory_screen: Control = $animation_nodes/VictoryScreen
@onready var game_over_screen: Control = $animation_nodes/GameOverScreen

var input_locked : bool = false
var in_cutscene : bool = false

@onready var virtual_joystick: VirtualJoystick = $animation_nodes/VirtualJoystick

func _ready() -> void:
	if virtual_joystick:
		virtual_joystick.visible = is_mobile()
	
	$AudioStreamPlayer.stream = load("res://assets/sound/gamemusic.mp3")
	$AudioStreamPlayer.volume_db = -10
	$AudioStreamPlayer.play()
	
	intro_cutscene()

func intro_cutscene()->void:
	in_cutscene = true
	input_locked = true
	player.is_in_cutscene = true
	
	# Fade in Title
	label.text = "The True Light"
	label.modulate = Color.WHITE
	var title_tween = create_tween()
	title_tween.tween_interval(1.0)
	title_tween.tween_property(label, "modulate", Color.TRANSPARENT, 2.0)
	
	# Initial Setup: Group of people around the light (CaveExit light)

	var exit_pos = $y_sort/CaveExit.global_position
	var npcs = []
	for i in range(5):
		var enemy_scene = load("res://enemy/enemy.tscn")
		var npc = enemy_scene.instantiate()
		$y_sort.add_child(npc)
		npc.global_position = exit_pos + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		npc.is_in_cutscene = true
		npc.sprite.modulate = Color.WHITE # Not cursed yet
		npcs.append(npc)
	 
	# Move camera to the group
	var cam = player.get_node("Camera2D")
	cam.reparent($y_sort) # Temporarily move camera to y_sort to animate freely
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(cam, "global_position", exit_pos, 2.0)
	
	game_anim_player.play("letterbox")
	
	await show_dialogue("For generations, we worshiped the Glimmer at the end of the tunnel.")
	await show_dialogue("We called it our sun, our god... our only hope in the eternal dark.")
	
	# NPCs 'praying' (simple bobbing)
	for npc in npcs:
		var npc_tween = create_tween().set_loops()
		npc_tween.tween_property(npc.sprite, "scale", Vector2(1.1, 0.9), 0.5)
		npc_tween.tween_property(npc.sprite, "scale", Vector2(1.0, 1.0), 0.5)
	
	await show_dialogue("But the cave gave nothing back. The roots withered. The water turned bitter.")
	await show_dialogue("Desperate, they begged for a miracle. For bread. For life.")
	
	# Screen shake or flicker
	var flicker_tween = create_tween().set_loops(20)
	flicker_tween.tween_property($CanvasModulate, "color", Color(0.1, 0.0, 0.1), 0.05)
	flicker_tween.tween_property($CanvasModulate, "color", Color.BLACK, 0.05)
	
	# Shake the camera during curse
	player.apply_shake(5.0, 1.0)
	
	await show_dialogue("But only silence answered... and then, the Hunger changed them.")

	
	# Cursing: Turn NPCs into enemies
	for npc in npcs:
		npc.sprite.modulate = Color(0.8, 0.4, 1.0) # Purple/Cursed
		# Play a small effect?
	
	await show_dialogue("Their prayers turned to screams. Their love to a violent, mindless hunger.")
	
	# NPCs start attacking each other or just acting wild
	for npc in npcs:
		npc.animation_player.play("attack")
	
	await show_dialogue("I am the only one left who still remembers what we were.")
	
	# Move camera back to player
	var back_tween = create_tween()
	back_tween.tween_property(cam, "global_position", player.global_position, 2.0)
	await back_tween.finished
	cam.reparent(player)
	cam.position = Vector2.ZERO
	
	await show_dialogue("I cannot stay here. I must see what lies beyond this light... or die trying.")
	
	game_anim_player.play_backwards("letterbox")
	input_locked = false
	in_cutscene = false
	player.is_in_cutscene = false
	
	# Clean up cutscene NPCs or leave them as enemies? 
	# Let's keep them as enemies but far away enough.
	for npc in npcs:
		npc.is_in_cutscene = false

func _input(event: InputEvent) -> void:
	if game_over_screen.visible and (event is InputEventMouseButton or event is InputEventKey):
		if event.is_pressed():
			get_tree().paused = false
			get_tree().reload_current_scene()

func win_game() -> void:
	in_cutscene = true
	input_locked = true
	player.is_in_cutscene = true
	
	await show_dialogue("Finally... the world above.")
	
	# Fade to white for "The Light"
	var tween = create_tween()
	$animation_nodes/ColorRect.visible = true
	$animation_nodes/ColorRect.color = Color(1, 1, 1, 0)
	tween.tween_property($animation_nodes/ColorRect, "color", Color.WHITE, 2.0)
	await tween.finished
	
	victory_screen.visible = true

func game_over() -> void:
	game_over_screen.visible = true
	get_tree().paused = true

func show_dialogue(text: String) -> void:
	dialogue_ui.visible = true
	dialogue_ui.modulate = Color.TRANSPARENT
	dialogue_label.text = text
	
	var tween = create_tween()
	tween.tween_property(dialogue_ui, "modulate", Color.WHITE, 0.5)
	
	await get_tree().create_timer(3.0).timeout
	
	var out_tween = create_tween()
	out_tween.tween_property(dialogue_ui, "modulate", Color.TRANSPARENT, 0.5)
	await out_tween.finished
	
	dialogue_ui.visible = false
	await get_tree().create_timer(0.2).timeout

func is_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS"]
