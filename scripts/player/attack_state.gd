extends State

var lerp_val = 0.09
@export var input_open := 0.25   # desde acá se acepta el próximo golpe (antes es muy pronto)
@export var chain_at := 0.5      # si hay golpe en cola, se encadena acá
@export var end_at := 0.9        # sin golpe en cola, se termina acá

var _step := 0
var _expected: StringName
var _queued := false

const ATTACK_NODES := ["Attack_1", "Attack_2", "Attack_3", "Attack_4"]

func enter():
	entity.set_combat_mode(true)
	_play(0)

func physics_update(delta: float):
	entity.apply_root_motion(delta)
	
	# Hasta que el tree llegue al golpe pedido, el progress es del anterior: esperar
	if entity.anim_state() != _expected:
		return

	var progress = entity.anim_progress()

	if Input.is_action_just_pressed("player_attack") and progress >= input_open:
		_queued = true

	if _queued and progress >= chain_at and _step < ATTACK_NODES.size() - 1:
		_play(_step + 1)
		return

	if progress >= end_at:
		transition.emit("LocomotionState" if entity.input_dir != Vector2.ZERO else "IdleState")

func _play(step: int) -> void:
	_step = step
	_expected = ATTACK_NODES[step]
	_queued = false
	entity.anim_travel(_expected)


func update(delta: float) -> void:
	pass

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func _on_animation_finished(anim_name: StringName):
	transition.emit("IdleState")
