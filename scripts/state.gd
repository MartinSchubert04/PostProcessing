class_name State
extends Node

signal transition

var player: CharacterBody3D  # referencia al owner
var state_machine: StateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(delta: float) -> void:
	pass
	
func update(delta: float) -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass
