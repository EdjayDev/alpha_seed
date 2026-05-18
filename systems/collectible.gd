extends Area2D
class_name Collectible

enum Type { LIGHT_FUEL, ATTACK_BOOST }

@export var type: Type = Type.LIGHT_FUEL
@export var amount: float = 10.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	match type:
		Type.LIGHT_FUEL:
			_apply_effect(body, "add_fuel")
		Type.ATTACK_BOOST:
			_apply_effect(body, "add_attack_boost")

	queue_free()


func _apply_effect(body: Node, method_name: String) -> void:
	if body.has_method(method_name):
		body.call(method_name, amount)
