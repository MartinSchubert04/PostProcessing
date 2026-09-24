extends State

@export var jump_speed = 5.0
@export var air_speed := 4.0
var lerp_val = 0.5

func enter():
	print("Salto")
	entity.velocity.y = jump_speed
	entity.playback.travel("Jump_Start")

func exit() -> void:
	pass

func physics_update(delta: float):
	var air_dir: Vector3 = entity.air_direction()
	if air_dir:
		entity.velocity.x = lerp(entity.velocity.x, air_dir.x * air_speed, lerp_val)
		entity.velocity.z = lerp(entity.velocity.z, air_dir.z * air_speed, lerp_val)
	
	if entity.velocity.y <= 0.0:
		transition.emit("FallState")
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
