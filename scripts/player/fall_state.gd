extends State

var lerp_val := 0.5
@export var hard_landing_height := 3.0
@export var air_speed := 4.0
@export var air_accel := 25.0
var fall_start_y := 0.0
const AIR_ANIMS = ["Jump_Loop", "Jump_Land"]

func enter():
	fall_start_y = entity.global_position.y
	entity.anim_travel("Jump_Loop")

func exit() -> void:
	pass

func physics_update(delta: float):
	var target: Vector3 = entity.direction * maxf(air_speed, Vector2(entity.velocity.x, entity.velocity.z).length())
	var h := Vector2(entity.velocity.x, entity.velocity.z) \
			  .move_toward(Vector2(target.x, target.z), air_accel * delta)
	entity.velocity.x = h.x
	entity.velocity.z = h.y

	if entity.wants_jump():  # coyote time
		transition.emit("JumpState")
		return	
	
	if entity.is_on_floor():
		var fall_height = fall_start_y - entity.global_position.y
		
		if fall_height >= hard_landing_height:
			
			transition.emit("LandState")
		elif entity.input_dir == Vector2.ZERO:
			transition.emit("IdleState")
		else: 
			transition.emit("LocomotionState")
		
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
