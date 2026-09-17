extends State

func enter():
	player.anim_tree.get("parameters/StateMachine/playback").travel("run")

func exit() -> void:
	player.anim_tree.get("parameters/StateMachine/playback").travel("run")

func physics_update(delta: float):
	if player.is_on_floor():
		transition.emit("Idle")
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
