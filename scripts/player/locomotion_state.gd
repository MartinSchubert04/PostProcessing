# run_state.gd
extends State

var speed = 0.0
var lerp_val = 0.5
const AIR_ANIMS := ["Jump_Start", "Jump_Loop", "Jump_Land"]

func enter():
	entity.anim_travel("Locomotion")

func exit() -> void:
	pass

func physics_update(delta: float):
	
	speed = entity.SPRINT_SPEED if Input.is_action_pressed("player_run") else entity.RUN_SPEED
	
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
		
	if Input.is_action_just_pressed("jump") and entity.is_on_floor():
		transition.emit("JumpState")
		return
		
	if Input.is_action_just_pressed("player_attack") and entity.combat_mode:
		transition.emit("AttackState")

func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
