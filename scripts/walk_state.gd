# walk_state.gd
extends State

@export var speed = 3.0
var lerp_val = 0.5

func enter():
	player.get_node("AnimationPlayer").play("walk")

func exit() -> void:
	player.get_node("AnimationPlayer").stop()
	

func physics_update(delta: float):
	
	if player.direction:
		player.velocity.x = lerp(player.velocity.x, player.direction.x * speed, lerp_val)
		player.velocity.z = lerp(player.velocity.z, player.direction.z * speed, lerp_val)
		player.armature.rotation.y = lerp_angle(player.armature.rotation.y, atan2(-player.velocity.x, -player.velocity.z) + PI, lerp_val)
	
	if player.input_dir == Vector2.ZERO:
		transition.emit("IdleState")
	if Input.is_action_pressed("player_run"):
		transition.emit("RunState")
		
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition.emit("JumpState")
	if Input.is_action_just_pressed("player_attack"):
		transition.emit("AttackState")


func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
