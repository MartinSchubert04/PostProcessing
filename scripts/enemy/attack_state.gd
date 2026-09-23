extends State

const ATTACK_NODE := "Sword_Attack"

var lerp_val = 0.09
var _attack_started := false

func enter():
	print("Attack")
	_attack_started = false
	entity.anim_tree.get("parameters/playback").travel(ATTACK_NODE)
	entity.move_blend = entity.BLEND_IDLE

func exit() -> void:
	pass

func physics_update(delta: float):
	entity.velocity.x = lerp(entity.velocity.x, 0.0, lerp_val)
	entity.velocity.z = lerp(entity.velocity.z, 0.0, lerp_val)
	
	var playback = entity.anim_tree.get("parameters/playback")
	if playback.get_current_node() == ATTACK_NODE:
		_attack_started = true
	elif _attack_started:
		transition.emit("FollowState")

func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
