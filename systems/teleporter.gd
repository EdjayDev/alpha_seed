extends Area2D
class_name Teleporter

@export var teleport_to : Marker2D
@export var teleport_transition_duration : float = 0

func _ready() -> void:
	body_entered.connect(teleport_body)

func teleport_body(body : CharacterBody2D)->void:
	body.global_position = teleport_to.global_position
