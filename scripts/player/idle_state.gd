# idle_state.gd
extends State

@export var speed = 0.0
var lerp_val = 0.5

func enter():
	entity.playback.travel("Locomotion")
	entity.move_blend = entity.BLEND_IDLE


func exit() -> void:
	pass

func physics_update(delta: float):
	
	entity.velocity.x = lerp(entity.velocity.x, 0.0, lerp_val)
	entity.velocity.z = lerp(entity.velocity.z, 0.0, lerp_val)
	
	var current = entity.playback.get_current_node()
	
	if current == "Jump_Land":
		return
	
	if not entity.is_on_floor():
		transition.emit("FallState")
		return
	
	if entity.input_dir != Vector2.ZERO:
		transition.emit("RunState")
		return
	
	if Input.is_action_just_pressed("jump") and entity.is_on_floor():
		transition.emit("JumpState")


func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
