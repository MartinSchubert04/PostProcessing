extends State

var lerp_val := 0.5
var speed := 4.0

func enter():
	entity.playback.travel("Jump_Loop")

func exit() -> void:
	pass

func physics_update(delta: float):

	if entity.direction:
		entity.velocity.x = lerp(entity.velocity.x, entity.direction.x * speed, lerp_val)
		entity.velocity.z = lerp(entity.velocity.z, entity.direction.z * speed, lerp_val)
	
	if entity.is_on_floor():
		if entity.input_dir == Vector2.ZERO:
			transition.emit("IdleState")
		else: 
			transition.emit("RunState")
		
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
