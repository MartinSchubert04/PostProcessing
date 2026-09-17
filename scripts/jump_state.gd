extends State

@export var jump_speed = 5.0
var lerp_val = 0.5

func enter():
	player.anim_tree.get("parameters/StateMachine/playback").travel("run")

func exit() -> void:
	player.anim_tree.get("parameters/StateMachine/playback").travel("run")

func physics_update(delta: float):
	player.lerp_val = lerp_val
	player.velocity.y = jump_speed
	
	#if player.velocity.y <= 0 and not player.is_onfloor():
		#transition.emit("FallState")
	if player.is_on_floor():
		_transition_on_land()
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func _transition_on_land():
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	if input_dir == Vector2.ZERO:
		transition.emit("IdleState")
	elif Input.is_action_pressed("player_run"):
		transition.emit("RunState")
	else:
		transition.emit("WalkState")
