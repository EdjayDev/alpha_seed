extends Node2D
class_name Main_Game

@onready var label: Label = $animation_nodes/TitleLabel
@onready var game_anim_player: AnimationPlayer = $animation_nodes/game_anim_player
@onready var player: Player = $y_sort/Player
@onready var dialogue_ui: Control = $animation_nodes/DialogueUI
@onready var dialogue_label: Label = $animation_nodes/DialogueUI/Panel/Label

@onready var animation_nodes: CanvasLayer = $animation_nodes

@onready var victory_screen: Control = $animation_nodes/VictoryScreen
@onready var game_over_screen: Control = $animation_nodes/GameOverScreen

var input_locked : bool = false
var in_cutscene : bool = false

@onready var virtual_joystick: VirtualJoystick = $animation_nodes/VirtualJoystick
@onready var screen_effect: ColorRect = $animation_nodes/screen_effect

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
	
	await show_dialogue("I cannot stay here. I must see what lies beyond this light... or die trying.")
	await wait(3.0)
	fade(6.0, "in")


	input_locked = false
	in_cutscene = false
	player.is_in_cutscene = false

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
	label.text = ""
	for text_char in text:
		label.text += text_char
	await get_tree().create_timer(3.0).timeout
	
	var out_tween = create_tween()
	out_tween.tween_property(dialogue_ui, "modulate", Color.TRANSPARENT, 0.5)
	await out_tween.finished
	
	dialogue_ui.visible = false
	await get_tree().create_timer(0.2).timeout

func fade(duration : float, type : String)->void:
	var tweener = create_tween()
	match type:
		"in":
			tweener.tween_property(screen_effect, "color:a", 0, duration)
		"out":
			tweener.tween_property(screen_effect, "color:a", 1.0, duration)
	
	
func is_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS"]

func wait(duration : float)->void:
	await get_tree().create_timer(duration).timeout
