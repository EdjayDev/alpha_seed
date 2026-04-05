extends Control

@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var health = player.get_node_or_null("HealthComponent")
		if health:
			health_bar.max_value = health.max_health
			health_bar.value = health.health
			health.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(_old_health: float, new_health: float) -> void:
	health_bar.value = new_health
