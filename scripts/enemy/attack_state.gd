extends State

const ATTACK_NODE := "Sword_Attack"

var lerp_val = 0.09
var _attacking := false
var _attack_started := false
var _next_attack_time := 0.0
var attack_interval := 2.5

func enter():
	entity.move_blend = entity.BLEND_IDLE
	_attacking = false
	_attack_started = false

func exit() -> void:
	_next_attack_time = 0.0
	pass

func physics_update(delta: float):
	var now = Time.get_ticks_msec() / 1000.0
	entity.velocity.x = lerp(entity.velocity.x, 0.0, lerp_val)
	entity.velocity.z = lerp(entity.velocity.z, 0.0, lerp_val)

	if not entity.target_in_attack_range:
		transition.emit("FollowState")
		return

	if not _attacking:
		entity.look_at_target(delta)
		if now >= _next_attack_time:
			entity.playback.travel(ATTACK_NODE)
			_attacking = true
		return

	var current = entity.playback_current
	if not _attack_started:
		if current == ATTACK_NODE:
			_attack_started = true
	elif current != ATTACK_NODE:
		_next_attack_time = now + attack_interval
		_attacking = false

func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
