class_name HealthComponent
extends Node

signal health_changed(old_health: float, new_health: float)
signal health_depleted()

@export var max_health: float = 100.0
@onready var health: float = max_health:
	set(value):
		var old_health = health
		health = clamp(value, 0.0, max_health)
		health_changed.emit(old_health, health)
		if health <= 0:
			health_depleted.emit()

func damage(amount: float) -> void:
	health -= amount

func heal(amount: float) -> void:
	health += amount
