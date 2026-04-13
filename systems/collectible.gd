extends Area2D
class_name Collectible

enum Type { LIGHT_FUEL, ATTACK_BOOST }

@export var type: Type = Type.LIGHT_FUEL
@export var amount: float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		match type:
			Type.LIGHT_FUEL:
				if body.has_method("add_fuel"):
					body.add_fuel(amount)
			Type.ATTACK_BOOST:
				if body.has_method("add_attack_boost"):
					body.add_attack_boost(amount)
		queue_free()
