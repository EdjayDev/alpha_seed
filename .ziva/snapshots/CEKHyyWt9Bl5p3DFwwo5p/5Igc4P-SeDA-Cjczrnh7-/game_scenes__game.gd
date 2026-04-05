extends Node2D
class_name Main_Game

@onready var label: Label = $animation_nodes/Control/Label
@onready var game_anim_player: AnimationPlayer = $animation_nodes/game_anim_player
@onready var player: Player = $y_sort/Player
@onready var dialogue_ui: Control = $animation_nodes/DialogueUI
@onready var dialogue_label: Label = $animation_nodes/DialogueUI/Panel/Label

var input_locked : bool = false
var in_cutscene : bool = false

@onready var virtual_joystick: VirtualJoystick = $animation_nodes/VirtualJoystick

func _ready() -> void:
	if virtual_joystick:
		virtual_joystick.visible = is_mobile()
	intro_cutscene()

func intro_cutscene()->void:
	in_cutscene = true
	input_locked = true
	game_anim_player.play("letterbox")
	player.player_animation.play("intro")
	
	await get_tree().create_timer(1.0).timeout
	
	await show_dialogue("Darkness... it's all we've ever known in this cave.")
	await show_dialogue("Generations have lived and died in these shadows, fearing the surface.")
	await show_dialogue("But they say light is life. Without it, we are just fading echoes.")
	await show_dialogue("I've seen a glimmer from the deep. A way out.")
	await show_dialogue("I must reach that light. I have to know what's beyond the dark.")
	
	game_anim_player.play_backward("letterbox")
	input_locked = false
	in_cutscene = false

func show_dialogue(text: String) -> void:
	dialogue_ui.visible = true
	dialogue_label.text = text
	# In a real game, you'd wait for a button press. Here we use a timer.
	await get_tree().create_timer(3.5).timeout
	dialogue_ui.visible = false
	await get_tree().create_timer(0.2).timeout

func is_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS"]
