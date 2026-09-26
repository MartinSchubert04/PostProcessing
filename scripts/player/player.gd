extends CharacterBody3D

signal hit

@onready var armature = $Armature
@onready var camera: Node3D = %Camera
@onready var anim_tree = %AnimationTree
@onready var hand_attachment: BoneAttachment3D = %SwordAttachment
@onready var back_attachment: BoneAttachment3D = %BackAttachment
@onready var sword_held: Node3D = %SwordAttachment/SwordHeld
@onready var sword_sheathed: Node3D = %BackAttachment/SwordSheathed
@onready var sword_collision: CollisionObject3D = %SwordAreaCollision
@onready var IK_controller: Node3D = %IKController
@onready var state_machine: StateMachine = $StateMachine
@onready var skel: Skeleton3D = %Skeleton3D
@onready var playback = anim_tree.get("parameters/Main/playback")
var playback_current

var direction: Vector3
var input_dir: Vector2
var speed: float
var lerp_val: float

var combat_mode: bool = false

var enemies_in_range: Array[Node3D] = []
@export_range(0, 180) var fov_horizontal_deg := 90.0  
@export_range(0, 90) var fov_vertical_deg := 35.0   
@export var eye_height := 1.6

enum { IDLE, WALK, WALK_STRAFE, RUN, JUMP, ATTACK, CROUCH_IDLE, CROUCH_WALK}
var currentAnim = IDLE
@export var blend_speed := 8.0
var locomotion_blend: Vector2
const BLEND_IDLE := 0.0
const BLEND_WALK := 0.5
const BLEND_SPRINT := 1.0
var move_blend := BLEND_IDLE

@export_group("Jump")
@export var jump_height := 1.6
@export var time_to_apex := 0.38
@export var time_to_fall := 0.28
@export var jump_cut_multiplier := 2.5 
@export var max_fall_speed := 25.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

@onready var jump_velocity := 2.0 * jump_height / time_to_apex
@onready var gravity_up := 2.0 * jump_height / (time_to_apex * time_to_apex)
@onready var gravity_down := 2.0 * jump_height / (time_to_fall * time_to_fall)

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

const WALK_SPEED := 1.65*2
const RUN_SPEED := 4.23*2
const SPRINT_SPEED := 7.76*2
const RUN_ANIM_SPEED = 4.23

func _ready() -> void:
	skel.reset_bone_pose(skel.find_bone("Root"))
	playback.start("Normal")
	sword_held.visible = combat_mode
	state_machine.start()
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
		
	var local: Vector3 = armature.global_basis.inverse() * Vector3(velocity.x, 0, velocity.z)
	var flat := Vector2(-local.x, local.z)
	var target := flat.normalized() * speed_to_blend(flat.length()) if flat.length() > 0.05 else Vector2.ZERO
	locomotion_blend = locomotion_blend.lerp(target, delta * blend_speed)
	anim_tree.set("parameters/Main/Normal/Locomotion/blend_position", locomotion_blend)
	anim_tree.set("parameters/Main/Combat/Locomotion/blend_position", locomotion_blend)

	_update_look_at_target()
	move_and_slide()

### ANIMATIONS ############################################
func apply_root_motion(delta: float) -> void:
	 # root_motion_local = true → el desplazamiento viene relativo a hacia dónde mira el armature
	var motion: Vector3 = armature.quaternion * anim_tree.get_root_motion_position()
	var h: Vector3 = global_basis * motion / delta
	velocity.x = h.x
	velocity.z = h.z    # velocity.y queda para la gravedad
	armature.quaternion *= anim_tree.get_root_motion_rotation()

func speed_to_blend(s: float) -> float:
	if s <= WALK_SPEED:
		return s / WALK_SPEED * 0.5
	return 0.5 + clampf((s - WALK_SPEED) / (RUN_SPEED - WALK_SPEED), 0.0, 1.0) * 0.5

func anim_travel(state: String):
	playback.travel(("Combat/" if combat_mode else "Normal/") + state)

func anim_state() -> StringName: # Current animation playing
	var mode := "Combat" if combat_mode else "Normal"
	return anim_tree.get("parameters/Main/%s/playback" % mode).get_current_node()

func anim_progress() -> float:   # 0..1 de la animación del estado actual
	var group: StringName = playback.get_current_node()
	if group == &"":
		return 0.0
	var pb: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/Main/%s/playback" % group)
	var length := pb.get_current_length()
	return pb.get_current_play_position() / length if length > 0.0 else 0.0

func set_combat_mode(enabled: bool) -> void:
	if enabled == combat_mode:
		return
	combat_mode = enabled
	anim_tree.set("parameters/Equip/transition_request", "draw" if enabled else "sheathe")
	anim_tree.set("parameters/EquipShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	anim_travel("Locomotion")
	get_tree().create_timer(0.4).timeout.connect(_update_sword)   # ~40% del desenvaine

func _update_sword() -> void:
	sword_held.visible = combat_mode
	sword_sheathed.visible = not combat_mode

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("combat_mode") and state_machine.current_state.name in ["IdleState", "LocomotionState"]:
		set_combat_mode(not combat_mode)

### SWORD ############################################

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
	var eye := global_position + Vector3.UP * eye_height
	var best_target: Node3D = null
	var best_angle := INF

	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue
		var to_enemy := enemy.global_position + Vector3.UP * eye_height - eye

		var local = armature.global_transform.basis.inverse() * to_enemy
		var yaw := rad_to_deg(atan2(local.x, local.z))
		var pitch := rad_to_deg(atan2(local.y, Vector2(local.x, local.z).length()))

		if absf(yaw) > fov_horizontal_deg or absf(pitch) > fov_vertical_deg:
			continue

		var angle := absf(yaw) + absf(pitch)
		if angle < best_angle:
			best_angle = angle
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
