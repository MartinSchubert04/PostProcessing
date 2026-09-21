# follow_state.gd
extends State

@export var speed = 7.0
var lerp_val = 0.5

func enter():
	entity.get_node("AnimationPlayer").play("enemy/run")
	entity.get_node("DetectArea").get_child(0).shape.radius *=  2

func exit() -> void:
	entity.get_node("AnimationPlayer").stop()
	entity.get_node("DetectArea").get_child(0).shape.radius /=  2
	

func physics_update(delta: float):
	if entity.target:
		entity.direction = global_position.direction_to(entity.target.global_position)
		entity.velocity.x = lerp(entity.velocity.x, entity.direction.x * speed, lerp_val)
		entity.velocity.z = lerp(entity.velocity.z, entity.direction.z * speed, lerp_val)
		entity.armature.global_rotation.y = lerp_angle(entity.armature.global_rotation.y, atan2(entity.direction.x, entity.direction.z), lerp_val)

	
	if not entity.target and entity.global_position.distance_to(entity.follow_path.global_position) >= 1.0:
		entity.direction = global_position.direction_to(entity.follow_path.global_position)
		entity.velocity.x = lerp(entity.velocity.x, entity.direction.x * speed, lerp_val)
		entity.velocity.z = lerp(entity.velocity.z, entity.direction.z * speed, lerp_val)
		entity.armature.global_rotation.y = lerp_angle(entity.armature.global_rotation.y, atan2(entity.direction.x, entity.direction.z), lerp_val)

	if not entity.target and entity.global_position.distance_to(entity.follow_path.global_position) < 1.0:
		entity.velocity.x = 0
		entity.velocity.z = 0
		transition.emit("PatrolState")
	

func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func _on_attack_area_body_entered(body: Node3D) -> void:
	#transition.emit("AttackState")
	pass

func _on_attack_area_body_exited(body: Node3D) -> void:
	pass
