extends CharacterBody3D

@onready var ani_tree: AnimationTree = $AnimationTree
@onready var follow_path: PathFollow3D = %PathFollow3D
@onready var armature: Node3D = %Armature
const SPEED = 2.0

var patrol_last_pos: Vector3
var player_in_range = false
var player_in_attack_range = false
var target: CharacterBody3D
var direction: Vector3
const LERP_VAL = 0.5

var last_hit_time = 0.0
var hit_interval = 0.5
var life = 100

func _physics_process(delta: float) -> void:
	
	move_and_slide()

func apply_damage():
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_hit_time > hit_interval:
		life -= 10
		if life <= 0: 
			die()

func die():
	queue_free()

func _on_player_hit() -> void:
	apply_damage()
