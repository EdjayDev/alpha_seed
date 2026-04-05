class_name Enemy
extends CharacterBody2D

@export var speed: float = 60.0
@export var attack_range: float = 50.0
@export var damage: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		# Fallback if group not set
		player = get_tree().get_root().find_child("Player", true, false) as Player

func _physics_process(delta: float) -> void:
	move_and_slide()
