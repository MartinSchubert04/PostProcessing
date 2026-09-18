# idle_state.gd
extends State

@export var speed = 0.0
var lerp_val = 0.5

func enter():
	player.get_node("AnimationPlayer").play("idle")

func exit() -> void:
	player.get_node("AnimationPlayer").stop()

func physics_update(delta: float):
	
	player.velocity.x = lerp(player.velocity.x, 0.0, lerp_val)
	player.velocity.z = lerp(player.velocity.z, 0.0, lerp_val)
	
	if player.input_dir != Vector2.ZERO:
		transition.emit("WalkState")
		return
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		transition.emit("JumpState")


func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
