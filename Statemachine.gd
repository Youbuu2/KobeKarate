# Extends the Node class from Godot Engine to create a StateMachine class.
extends Node
class_name StateMachine
# Variables to hold the current state, previous state, and a dictionary of all states.
var state = null setget set_state
var previous_state = null
var states = {}
# Reference to the parent node of this state machine node.
onready var parent = get_parent()
# Called every physics frame; it updates state logic and handles state transitions.

func _physics_process(delta):
	if state != null:
		state_logic(delta)
		var transition = get_transition(delta)
		if transition != null:
			set_state(transition)
# Placeholder function for state-specific logic to be implemented in subclasses.
func state_logic(delta):
	pass
# Placeholder function to determine if a state transition should occur, to be overridden.
# Made to accomodate for wakeup states but didn't get around to said implementation
func get_transition(delta):
	return null
func enter_state(new_state, old_state):
	pass
func exit_state(old_state, new_state):
	pass
# Setter for the state variable that manages state transitions and calls relevant functions.
func set_state(new_state):
	previous_state = state
	state = new_state
	if previous_state != null:
		exit_state(previous_state, new_state)
	if new_state != null:
			enter_state(new_state, previous_state)
# Adds a new state to the states dictionary with a unique integer ID.
func add_state(state_name):
	states[state_name] = states.size()
