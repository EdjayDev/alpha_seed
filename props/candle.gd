class_name Candle
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light: PointLight2D = $PointLight2D

func _ready() -> void:
	animated_sprite.play("flicker")

func _process(_delta: float) -> void:
	# Small flicker effect for the light too
	if point_light:
		point_light.energy = randf_range(0.8, 1.2)
