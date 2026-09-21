class_name StateMachine
extends Node

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Give each child state a reference back to this machine and player
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(_on_state_transition)
			child.state_machine = self
			child.entity = owner

	if initial_state:
		current_state = initial_state
		current_state.enter()

func start():
	if initial_state:
		current_state = initial_state
		current_state.enter()

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _on_state_transition(target_state_name: String) -> void:
	var target_state = states.get(target_state_name.to_lower())
	
	if current_state == target_state:
		return
		
	if current_state:
		current_state.exit()
		current_state = target_state
		current_state.enter()
