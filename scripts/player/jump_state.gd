extends State

@export var jump_speed = 5.0
@export var air_speed := 4.0
var lerp_val = 0.5
@export var air_accel := 25.0
var takeoff_speed := 0.0

func enter():
	takeoff_speed = Vector2(entity.velocity.x, entity.velocity.z).length()
	entity.consume_jump()
	entity.playback.travel("Jump_Start")

func exit() -> void:
	pass

func physics_update(delta: float):
	var max_speed := maxf(air_speed, takeoff_speed)
	var target: Vector3 = entity.direction * max_speed
	var h := Vector2(entity.velocity.x, entity.velocity.z) \
		.move_toward(Vector2(target.x, target.z), air_accel * delta)
	entity.velocity.x = h.x
	entity.velocity.z = h.y
	entity.armature.rotation.y = lerp_angle(entity.armature.rotation.y, atan2(-entity.velocity.x, -entity.velocity.z) + PI, lerp_val)

	if entity.velocity.y <= 0.0:
		transition.emit("FallState")
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
