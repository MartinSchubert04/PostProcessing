# patrol_state.gd
extends State

@export var speed = 1.0
var lerp_val = 0.5

func enter():
	print("Patrol")
	entity.anim_tree.get("parameters/playback").travel("Locomotion")
	entity.move_blend = entity.BLEND_WALK

func exit() -> void:
	pass

func physics_update(delta: float):
	entity.follow_path.progress += speed * delta
	entity.patrol_last_pos = entity.position
	
	var d = -entity.follow_path.global_basis.z
	entity.armature.global_rotation.y = lerp_angle(entity.armature.global_rotation.y, atan2(d.x, d.z), lerp_val)


func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass


func _on_detect_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		entity.target = body
		transition.emit("FollowState")

func _on_detect_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		entity.target = null
