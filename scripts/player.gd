extends CharacterBody3D

@onready var armature = $Armature
@onready var camera: Node3D = %Camera
@onready var ani_tree = $AnimationTree
@onready var anim_player: AnimationPlayer = $Armature/AnimationPlayer
@onready var sword_attachment: BoneAttachment3D = %SwordAttachment
@onready var back_attachment: BoneAttachment3D = $BackAttachment
@onready var sword: Node3D = $BackAttachment/DragonSlayer

const SPEED = 5.0
const JUMP_VELOCITY = 7.5
const LERP_VAL = 0.5

var running: bool = false
var speed_boost = 0.0

func _ready() -> void:
	ani_tree.active = true
	camera.set_following(self)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("run"):
		speed_boost = 10
	else:
		speed_boost = 0.0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera.rotation.y).normalized()

	if direction:
		velocity.x = lerp(velocity.x, direction.x * (SPEED + speed_boost), LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * (SPEED + speed_boost), LERP_VAL)
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z) + PI, LERP_VAL)
		running = true
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
		running = false
	
	if !velocity.y or (velocity.y and velocity.x != 0 and velocity.z != 0):
		ani_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / SPEED)
		
	handle_sword_position()
	
	move_and_slide()
	

func handle_sword_position():
	if running:
		sword_attachment.set("bone_name", "mixamorig_Spine2")
	else: 
		sword_attachment.set("bone_name", "mixamorig_RightHand")
	
	
