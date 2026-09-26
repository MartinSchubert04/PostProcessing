extends State

@export var brake := 100.0
var recover_at = 0.8
var end_at = 0.9

func enter():
	entity.anim_travel("Jump_Land")

func exit() -> void:
	pass

func physics_update(delta: float):
	entity.velocity.x = move_toward(entity.velocity.x, 0.0, brake * delta)
	entity.velocity.z = move_toward(entity.velocity.z, 0.0, brake * delta)
	
	if entity.anim_state() != "Jump_Land":
		return
	
	var progress = entity.anim_progress()
	var moving = entity.input_dir != Vector2.ZERO
	if progress >= end_at or (moving and progress >= recover_at):
		transition.emit("LocomotionState" if moving else "IdleState")
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func is_strong_fall():
	return entity.velocity.y <= -0.1
