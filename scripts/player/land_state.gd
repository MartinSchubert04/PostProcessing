extends State

@export var brake := 30.0
var land_started := false

func enter():
	land_started = false
	entity.playback.travel("Jump_Land")

func exit() -> void:
	pass

func physics_update(delta: float):
	entity.velocity.x = move_toward(entity.velocity.x, 0.0, brake * delta)
	entity.velocity.z = move_toward(entity.velocity.z, 0.0, brake * delta)
	
	var current = entity.playback_current
	if current == "Jump_Land":
		land_started = true
	elif land_started:
		if entity.input_dir == Vector2.ZERO:
			transition.emit("IdleState")
		else:
			transition.emit("RunState")
		
	
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func is_strong_fall():
	return entity.velocity.y <= -0.1
