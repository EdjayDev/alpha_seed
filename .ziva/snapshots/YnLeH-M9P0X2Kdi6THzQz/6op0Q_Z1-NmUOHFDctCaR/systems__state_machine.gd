class_name StateMachine
extends Node

## Manages states and transitions between them.

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if get_parent().get("is_in_cutscene"):
		return
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if get_parent().get("is_in_cutscene"):
		return
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state_name: String) -> void:
	var new_state = states.get(state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit()
	
	new_state.enter()
	current_state = new_state
