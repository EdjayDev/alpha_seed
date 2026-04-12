extends Node2D
@onready var point_light: PointLight2D = $PointLight2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	point_light.energy = randf_range(0.75, 1.5)
