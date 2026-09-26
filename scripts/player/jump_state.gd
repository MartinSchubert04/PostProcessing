extends State

@export var air_speed := 4.0
@export var air_accel := 25.0
@export var takeoff_delay := 0.1  # allow crouch at the beginning
var lerp_val = 0.5
var takeoff_speed := 0.0
var _windup := 0.0
var _jumped := false

func enter():
	takeoff_speed = Vector2(entity.velocity.x, entity.velocity.z).length()
	_windup = 0.0
	_jumped = false
	if takeoff_speed < 0.1:
		entity.anim_travel("Jump_Start")
	else:
		entity.anim_travel("Jump_Loop")
		
func exit() -> void:
	pass

func physics_update(delta: float):
	if not _jumped:
		# check if is a edge fall
		if not entity.is_on_floor():
			transition.emit("FallState")
			return
		_windup += delta
		if _windup < takeoff_delay:
			return
		entity.consume_jump()
		_jumped = true
		return

	var max_speed := maxf(air_speed, takeoff_speed)
	var target: Vector3 = entity.direction * max_speed
	var h := Vector2(entity.velocity.x, entity.velocity.z) \
		.move_toward(Vector2(target.x, target.z), air_accel * delta)
	entity.velocity.x = h.x
	entity.velocity.z = h.y
	
	var h_vel := Vector2(entity.velocity.x, entity.velocity.z)
	if entity.direction and h_vel.length() > 0.5:
		entity.armature.rotation.y = lerp_angle(entity.armature.rotation.y, atan2(-entity.velocity.x, -entity.velocity.z) + PI, lerp_val)

	if entity.velocity.y <= 0.0:
		transition.emit("FallState")
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
