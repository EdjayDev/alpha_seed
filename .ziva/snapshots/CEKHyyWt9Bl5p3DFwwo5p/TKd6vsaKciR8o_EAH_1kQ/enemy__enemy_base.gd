class_name Enemy
extends CharacterBody2D

@export var speed: float = 60.0
@export var attack_range: float = 50.0
@export var damage: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent

var player: Player

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	if not player:
		# Fallback if group not set
		player = get_tree().get_root().find_child("Player", true, false) as Player
	
	if health_component:
		health_component.health_depleted.connect(_on_died)

func _on_died() -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	move_and_slide()
