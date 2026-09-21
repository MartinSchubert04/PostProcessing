extends State

var lerp_val = 0.09

func enter():
	entity.get_node("AnimationPlayer").play("great_sword/slash")
	
func exit() -> void:
	entity.get_node("AnimationPlayer").stop()

func physics_update(delta: float):
	entity.velocity.x = lerp(entity.velocity.x, 0.0, lerp_val)
	entity.velocity.z = lerp(entity.velocity.z, 0.0, lerp_val)


func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func _on_animation_finished(anim_name: StringName):
	transition.emit("IdleState")
