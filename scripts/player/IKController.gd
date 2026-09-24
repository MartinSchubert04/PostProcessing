extends Node3D

@onready var l_leg: TwoBoneIK3D = %l_leg
@onready var r_leg: TwoBoneIK3D = %r_leg
@onready var r_arm: TwoBoneIK3D = %r_arm
@onready var l_arm: TwoBoneIK3D = %l_arm
@onready var look_at: LookAtModifier3D = %LookAt

var look_target: Node3D = null
var target_influence: float = 0.0
@export var influence_lerp_speed: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	l_leg.active = false
	r_leg.active = false
	r_arm.active = false
	l_arm.active = false
	look_at.active = false
	pass

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at.influence = lerp(look_at.influence, target_influence, delta * influence_lerp_speed)
	
	if look_at.influence < 0.01 and target_influence == 0.0:
		look_at.active = false

func set_look_at(body: Node3D):
	look_target = body
	look_at.target_node = look_at.get_path_to(body.get_node("Armature/Skeleton3D/HeadAttachment/LookAtMarker"))
	look_at.active = true
	target_influence = 1.0


func disable_look_at():
	target_influence = 0.0
	look_target = null
