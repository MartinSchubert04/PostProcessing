extends CharacterBody3D

@onready var ani_tree: AnimationTree = $AnimationTree
@onready var anim_player = %AnimationPlayer
@onready var anim_tree = %AnimationTree
@onready var follow_path: PathFollow3D = %PathFollow3D
@onready var armature: Node3D = %Armature
@onready var state_machine: StateMachine = $StateMachine

const MAX_SPEED = 2.0
@export var blend_speed := 8.0
const BLEND_IDLE := 0.0
const BLEND_WALK := 0.5
const BLEND_SPRINT := 1.0
var move_blend := BLEND_IDLE

var patrol_last_pos: Vector3
var player_in_range = false
var player_in_attack_range = false
var target: CharacterBody3D
var direction: Vector3

var last_hit_time = 0.0
var hit_interval = 0.5
var life = 100

func _ready() -> void:
	state_machine.start()

func _physics_process(delta: float) -> void:
	var current: float = anim_tree.get("parameters/Locomotion/blend_position")
	anim_tree.set("parameters/Locomotion/blend_position", lerp(current, move_blend, delta * blend_speed))
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
