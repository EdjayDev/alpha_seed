extends Node2D
class_name Main_Game

var time : Timer
@onready var label: Label = $animation_nodes/Control/Label
@onready var game_anim_player: AnimationPlayer = $animation_nodes/game_anim_player
@onready var player: Player = $y_sort/Player
var input_locked : bool = false
var in_cutscene : bool = false

@onready var virtual_joystick: VirtualJoystick = $animation_nodes/VirtualJoystick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	virtual_joystick.visible = is_mobile()
	await intro_cutscene()
	set_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func intro_cutscene()->void:
	in_cutscene = true
	input_locked = true
	player.player_animation.play("intro")
	game_anim_player.play("letterbox")
	await game_anim_player.animation_finished
	input_locked = false
	in_cutscene = false

func set_timer()->void:
	pass

func is_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS"]
