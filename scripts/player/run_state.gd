# run_state.gd
extends State

@export var speed = 12.0
var lerp_val = 0.5

func enter():
	print("Corro")
	entity.playback.travel("Locomotion")
	entity.move_blend = entity.BLEND_SPRINT

func exit() -> void:
	pass

func physics_update(delta: float):
	
	if not entity.is_on_floor():
		transition.emit("FallState")
		return
	
	if entity.direction:
		entity.velocity.x = lerp(entity.velocity.x, entity.direction.x * speed, lerp_val)
		entity.velocity.z = lerp(entity.velocity.z, entity.direction.z * speed, lerp_val)
		entity.armature.rotation.y = lerp_angle(entity.armature.rotation.y, atan2(-entity.velocity.x, -entity.velocity.z) + PI, lerp_val)
		
	if entity.input_dir == Vector2.ZERO:	
		transition.emit("IdleState")
		return 
		
	#if Input.is_action_just_released("player_run"):
		#transition.emit("WalkState")
		#return
		
	if Input.is_action_just_pressed("jump") and entity.is_on_floor():
		transition.emit("JumpState")
		return
		
	if Input.is_action_just_pressed("player_attack"):
		transition.emit("AttackState")
		return

func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
