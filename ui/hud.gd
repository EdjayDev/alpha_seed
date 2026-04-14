extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var fuel_bar: ProgressBar = $FuelBar

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var health = player.get_node_or_null("HealthComponent")
		if health:
			health_bar.max_value = health.max_health
			health_bar.value = health.health
			health.health_changed.connect(_on_player_health_changed)
		
		fuel_bar.max_value = player.max_fuel
		fuel_bar.value = player.fuel
		player.fuel_changed.connect(_on_player_fuel_changed)

func _on_player_health_changed(_old_health: float, new_health: float) -> void:
	health_bar.value = new_health

func _on_player_fuel_changed(new_fuel: float) -> void:
	fuel_bar.value = new_fuel
