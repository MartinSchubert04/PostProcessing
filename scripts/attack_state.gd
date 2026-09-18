extends State

var lerp_val = 0.09

func enter():
	player.get_node("AnimationPlayer").play("great_sword/slash")
	if not player.get_node("AnimationPlayer").animation_finished.is_connected(_on_animation_finished):
		player.get_node("AnimationPlayer").animation_finished.connect(_on_animation_finished)
	player.sword_held.visible = true
	player.sword_sheathed.visible = false
	
	
func exit() -> void:
	player.get_node("AnimationPlayer").stop()

func physics_update(delta: float):
	player.velocity.x = lerp(player.velocity.x, 0.0, lerp_val)
	player.velocity.z = lerp(player.velocity.z, 0.0, lerp_val)


func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func _on_animation_finished(anim_name: StringName):
	transition.emit("IdleState")
