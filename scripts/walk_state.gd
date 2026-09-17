# walk_state.gd
extends State

@export var speed = 3.0
var lerp_val = 0.5

func enter():
	player.get_node("AnimationPlayer").play("walk")

func exit() -> void:
	player.get_node("AnimationPlayer").stop()
	

func physics_update(delta: float):
	player.lerp_val = lerp_val
	player.speed = speed
	
	if player.input_dir == Vector2.ZERO:
		transition.emit("IdleState")
	if Input.is_action_pressed("player_run"):
		transition.emit("RunState")
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition.emit("JumpState")

func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
