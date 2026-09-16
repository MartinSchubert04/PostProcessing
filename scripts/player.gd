extends CharacterBody3D

signal hit

@onready var armature = $Armature
@onready var camera: Node3D = %Camera
@onready var ani_tree = $AnimationTree
@onready var anim_player: AnimationPlayer = $Armature/AnimationPlayer
@onready var hand_attachment: BoneAttachment3D = %SwordAttachment
@onready var back_attachment: BoneAttachment3D = %BackAttachment
@onready var sword_held: Node3D = %SwordAttachment/SwordHeld
@onready var sword_sheathed: Node3D = %BackAttachment/SwordSheathed
@onready var sword_collision: CollisionObject3D = %SwordAreaCollision
@onready var IK_controller: Node3D = %IKController


var run_speed = 7.0
var walk_speed = 3.0
var current_speed = walk_speed
const JUMP_VELOCITY = 7.5
const LERP_VAL = 0.5
var direction: Vector3

var combat_mode: bool = false
var speed_boost = 0.0

var enemies_in_range: Array[Node3D] = []
var fov_half_angle_degrees = 90.0
var fov_threshold = cos(deg_to_rad(fov_half_angle_degrees)) 

enum { IDLE, WALK, WALK_STRAFE, RUN, JUMP, ATTACK, CROUCH_IDLE, CROUCH_WALK}
var currentAnim = IDLE
@export var blend_speed = 15
var run_val = 0
var jump_val = 0
var walk_val = 0

func _ready() -> void:
	handle_sword_position()
	ani_tree.active = true
	camera.set_following(self)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		currentAnim = JUMP
	elif Input.is_action_pressed("player_run"):
		currentAnim = RUN
	elif is_moving():
		currentAnim = WALK
	else:
		currentAnim = IDLE

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera.rotation.y).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * current_speed, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * current_speed, LERP_VAL)
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z) + PI, LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
	
	handle_animations(delta)
	update_ani_tree()
	_update_look_at_target()
	move_and_slide()
	

### SWORD ############################################

func handle_sword_position():
	sword_held.visible = combat_mode
	sword_sheathed.visible = not combat_mode

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("combat_mode"):
		combat_mode = not combat_mode
		handle_sword_position()
	if event.is_action_pressed("player_run"):
		current_speed = run_speed
	if event.is_action_released("player_run"):
		current_speed = walk_speed


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

func handle_animations(delta):
	match currentAnim:
		IDLE:
			reset_animation_vals(delta)
		WALK:
			reset_animation_vals(delta)
			walk_val = lerpf(walk_val, 1, blend_speed * delta)
		RUN:
			reset_animation_vals(delta)
			run_val = lerpf(run_val, 1, blend_speed * delta)
		JUMP:
			reset_animation_vals(delta)
			jump_val = lerpf(jump_val, 1, blend_speed * delta)

func reset_animation_vals(delta):
	run_val = lerpf(run_val, 0, blend_speed * delta)
	walk_val = lerpf(walk_val, 0, blend_speed * delta)
	jump_val = lerpf(jump_val, 0, blend_speed * delta)

func update_ani_tree():
	ani_tree["parameters/walk/blend_amount"] = walk_val
	ani_tree["parameters/run/blend_amount"] = run_val
	ani_tree["parameters/walk/blend_amount"] = walk_val

func is_moving():
	return Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_back")
