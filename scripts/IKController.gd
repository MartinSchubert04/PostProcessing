extends Node3D

@onready var l_leg: TwoBoneIK3D = %l_leg
@onready var r_leg: TwoBoneIK3D = %r_leg
@onready var r_arm: TwoBoneIK3D = %r_arm
@onready var l_arm: TwoBoneIK3D = %l_arm
@onready var look_at: LookAtModifier3D = %LookAt

var look_target: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	l_leg.influence = 0.0
	r_leg.influence = 0.0
	r_arm.influence = 0.0
	l_arm.influence = 0.0
	look_at.influence = 0.0
	#_update_foot_ik(delta)
	
	#var target_influence = 1.0 if look_target else 0.0
	#look_at.influence = lerp(look_at.influence, target_influence, delta * 5.0)

func set_look_at_head(target: Node3D):
	look_target = target
