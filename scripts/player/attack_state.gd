extends State

var lerp_val = 0.09
var _attacking := false
var _attack_started := false
var _next_attack_time := 0.0
var attack_interval := 2.5

const ATTACK_NODE := "Sword_Attack"

func enter():
	entity.sword_held.visible = true
	entity.sword_sheathed.visible = false
	_attacking = false
	_attack_started = false
	
	
func exit() -> void:
	pass

func physics_update(delta: float):
	var now = Time.get_ticks_msec() / 1000.0
	entity.velocity.x = lerp(entity.velocity.x, 0.0, lerp_val)
	entity.velocity.z = lerp(entity.velocity.z, 0.0, lerp_val)
	
	
	
	if not _attacking:
		#entity.look_at_target(delta)
		#if now >= _next_attack_time:
		entity.playback.travel(ATTACK_NODE)
		_attacking = true
		return
		
	var current = entity.playback.get_current_node()
	
	if not _attack_started:
		if current == ATTACK_NODE:
			_attack_started = true
	elif current != ATTACK_NODE:
		_attacking = false
		transition.emit("IdleState")


func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func _on_animation_finished(anim_name: StringName):
	transition.emit("IdleState")
