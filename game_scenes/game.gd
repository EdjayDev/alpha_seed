extends Node2D
class_name Main_Game

var time : Timer
@onready var label: Label = $animation_nodes/Control/Label
@onready var game_anim_player: AnimationPlayer = $animation_nodes/game_anim_player
@onready var player: Player = $y_sort/Player
var input_locked : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await intro_cutscene()
	set_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func intro_cutscene()->void:
	input_locked = true
	player.player_animation.play("intro")
	game_anim_player.play("letterbox")
	await game_anim_player.animation_finished
	input_locked = false

func set_timer()->void:
	
	pass
