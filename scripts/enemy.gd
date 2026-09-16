extends CharacterBody3D

@onready var ani_tree: AnimationTree = $AnimationTree
const SPEED = 2.0

var player_in_range = false
var target: CharacterBody3D
var direction: Vector3
const LERP_VAL = 0.5

var last_hit_time = 0.0
var hit_interval = 0.5
var life = 100

func _physics_process(delta: float) -> void:
	if player_in_range:
		direction = global_position.direction_to(target.global_position)
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
	
	move_and_slide()

func apply_damage():
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_hit_time > hit_interval:
		life -= 10
		if life <= 0: 
			die()

func die():
	queue_free()

func _on_ray_cast_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = body
		player_in_range = true

func _on_ray_cast_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		target = null
		player_in_range = false

func _on_player_hit() -> void:
	apply_damage()
