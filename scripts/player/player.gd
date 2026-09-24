extends CharacterBody3D

signal hit

@onready var armature = $Armature
@onready var camera: Node3D = %Camera
@onready var anim_tree = %AnimationTree
@onready var anim_player = $AnimationPlayer
@onready var hand_attachment: BoneAttachment3D = %SwordAttachment
@onready var back_attachment: BoneAttachment3D = %BackAttachment
@onready var sword_held: Node3D = %SwordAttachment/SwordHeld
@onready var sword_sheathed: Node3D = %BackAttachment/SwordSheathed
@onready var sword_collision: CollisionObject3D = %SwordAreaCollision
@onready var IK_controller: Node3D = %IKController
@onready var state_machine: StateMachine = $StateMachine

@onready var playback = anim_tree.get("parameters/playback")
var playback_current

var direction: Vector3
var input_dir: Vector2
var speed: float
var lerp_val: float

var combat_mode: bool = false

var enemies_in_range: Array[Node3D] = []
var fov_half_angle_degrees = 90.0
var fov_threshold = cos(deg_to_rad(fov_half_angle_degrees)) 

enum { IDLE, WALK, WALK_STRAFE, RUN, JUMP, ATTACK, CROUCH_IDLE, CROUCH_WALK}
var currentAnim = IDLE
@export var blend_speed := 8.0
const BLEND_IDLE := 0.0
const BLEND_WALK := 0.5
const BLEND_SPRINT := 1.0
var move_blend := BLEND_IDLE

@export_group("Jump")
@export var jump_height := 1.6
@export var time_to_apex := 0.38
@export var time_to_fall := 0.28      # menor que time_to_apex = cae más rápido de lo que sube
@export var jump_cut_multiplier := 2.5 # gravedad extra si soltás el botón (altura variable)
@export var max_fall_speed := 25.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

@onready var jump_velocity := 2.0 * jump_height / time_to_apex
@onready var gravity_up := 2.0 * jump_height / (time_to_apex * time_to_apex)
@onready var gravity_down := 2.0 * jump_height / (time_to_fall * time_to_fall)

var coyote_timer := 0.0
var jump_buffer_timer := 0.0


func _ready() -> void:
	sword_held.visible = combat_mode
	state_machine.start()
	anim_tree.active = true
	camera.set_following(self)


func _physics_process(delta: float) -> void:
	playback_current = playback.get_current_node()
	
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		velocity.y = maxf(velocity.y - _current_gravity() * delta, -max_fall_speed)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera.rotation.y).normalized()
		
	var current: float = anim_tree.get("parameters/Locomotion/blend_position")
	anim_tree.set("parameters/Locomotion/blend_position", lerp(current, move_blend, delta * blend_speed))
	
	_update_look_at_target()
	move_and_slide()
	

### SWORD ############################################

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("combat_mode"):
		combat_mode = not combat_mode

func _on_sword_area_collision_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		hit.emit()

### LOOK AT ############################################

func _on_detect_enemy_body_entered(body: Node3D) -> void:
	enemies_in_range.append(body)

func _on_detect_enemy_body_exited(body: Node3D) -> void:
	enemies_in_range.erase(body)
	if IK_controller.look_target == body:
		IK_controller.disable_look_at()

func _update_look_at_target():
	var forward = armature.global_transform.basis.z
	var best_target: Node3D = null
	var best_dot = fov_threshold
	
	for enemy in enemies_in_range:
		var to_enemy = global_position.direction_to(enemy.global_position)
		var dot_result = to_enemy.dot(forward)
		if dot_result > best_dot:
			best_dot = dot_result
			best_target = enemy
	
	if best_target and IK_controller.look_target != best_target:
		IK_controller.set_look_at(best_target)
	elif not best_target and IK_controller.look_target != null:
		IK_controller.disable_look_at()

### JUMP ############################################

func _current_gravity() -> float:
	if velocity.y > 0.0:
		return gravity_up if Input.is_action_pressed("jump") else gravity_up * jump_cut_multiplier
	return gravity_down

func wants_jump() -> bool:
	return jump_buffer_timer > 0.0 and coyote_timer > 0.0

func consume_jump() -> void:
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	velocity.y = jump_velocity
