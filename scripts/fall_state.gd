extends State

func enter():
	entity.anim_tree.get("parameters/StateMachine/playback").travel("run")

func exit() -> void:
	entity.anim_tree.get("parameters/StateMachine/playback").travel("run")

func physics_update(delta: float):
	if entity.is_on_floor():
		transition.emit("Idle")
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
