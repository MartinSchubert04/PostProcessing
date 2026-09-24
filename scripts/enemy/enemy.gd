extends CharacterBody3D

@onready var ani_tree: AnimationTree = $AnimationTree
@onready var anim_player = %AnimationPlayer
@onready var anim_tree = %AnimationTree
@onready var follow_path: PathFollow3D = %PathFollow3D
@onready var armature: Node3D = %Armature
@onready var state_machine: StateMachine = $StateMachine

@onready var playback = anim_tree.get("parameters/playback")
var playback_current

const MAX_SPEED = 2.0
@export var blend_speed := 8.0
const BLEND_IDLE := 0.0
const BLEND_WALK := 0.5
const BLEND_SPRINT := 1.0
var move_blend := BLEND_IDLE
var lerp_val := 0.5
var turn_speed := 8.0

var patrol_last_pos: Vector3
var target_in_range = false
var target_in_attack_range := false
var target: CharacterBody3D
var direction: Vector3

var last_hit_time = 0.0
var hit_interval = 0.5
var life = 100

func _ready() -> void:
	state_machine.start()

func _physics_process(delta: float) -> void:
	playback_current = playback.get_current_node()
	
	var current: float = anim_tree.get("parameters/Locomotion/blend_position")
	anim_tree.set("parameters/Locomotion/blend_position", lerp(current, move_blend, delta * blend_speed))
	move_and_slide()

func apply_damage():
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_hit_time > hit_interval:
		life -= 10
		if life <= 0: 
			die()

func look_at_target(delta: float):
	if not target:
		return
	var to_target := target.global_position - global_position
	to_target.y = 0.0
	if to_target.length_squared() < 0.0001:
		return
	var goal := atan2(to_target.x, to_target.z)
	var t := 1.0 - exp(-turn_speed * delta)
	armature.global_rotation.y = lerp_angle(armature.global_rotation.y, goal, t)


func die():
	queue_free()

func _on_player_hit() -> void:
	apply_damage()
