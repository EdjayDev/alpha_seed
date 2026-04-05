class_name Enemy
extends CharacterBody2D

@export var speed: float = 60.0
@export var attack_range: float = 14.0
@export var damage: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: Node = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var health_bar: ProgressBar = $HealthBar

var player: Player

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().get_root().find_child("Player", true, false) as Player
	
	if health_component:
		health_component.health_depleted.connect(_on_died)
		if health_bar:
			health_bar.max_value = health_component.max_health
			health_bar.value = health_component.health
			health_component.health_changed.connect(_on_health_changed)

func _on_health_changed(_old_health: float, new_health: float) -> void:
	if health_bar:
		health_bar.value = new_health

func _on_died() -> void:
	queue_free()

func _physics_process(_delta: float) -> void:
	move_and_slide()
