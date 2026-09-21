class_name State
extends Node3D

signal transition

var entity: CharacterBody3D
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
