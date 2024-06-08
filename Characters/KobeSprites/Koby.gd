extends KinematicBody2D
var states_text = ""
# Movement-related variables defining the velocity and durations for actions.
#General Var
var frame = 0  # A frame counter used to manage timing for actions.
export var id: int

#ATTRIBUTES
export var percentage = 0
export var stocks = 3
export var weight = 100

#KNOCKBACK VARS
var horizontalDecay
var verticleDecay
var knockback
var hitstun
var connected:bool

#Ground VAr
var velocity = Vector2(0,0)
var dash_duration = 10  # Duration for which the dash state is active.
var facing = 1  # 1 for right, -1 for left

#Air Var
var landing_frames = 0
var lag_frames= 0
var jump_squat = 1
var fastfall = false

#Hitboxes
export var hitbox: PackedScene
var selfState

#Onready Var
onready var GroundL = get_node("Raycasts/GroundL")
onready var GroundR = get_node("Raycasts/GroundR")
onready var Ledge_Grab_F = get_node("Raycasts/Ledge_Grab_F")
onready var Ledge_Grab_B = get_node("Raycasts/Ledge_Grab_B")
onready var states = $State
onready var anim = $Sprite/AnimationPlayer

# Speed and movement constants.
var RUNSPEED = 340
var DASHSPEED = 410
var WALKSPEED = 200
var GRAVITY = 1800
var JUMPFORCE = 500
var MAX_JUMPFORCE = 800
var DOUBLEJUMPFORCE = 1000
var MAXAIRSPEED = 300
var AIR_ACCEL = 25
var FALLSPEED = 60
var FALLINGSPEED = 900
var MAXFALLSPEED = 900
var TRACTION = 70
var ROLL_DISTANCE = 350
var air_dodge_speed = 500
var UP_B_LAUNCHSPEED = 700






func direction():
	if Ledge_Grab_F.get_cast_to().x>0:
		return 1
	else:
		return -1



##func create_hitbox(width, height, damage, angle,base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag=1):
##	var hitbox_instance = hitbox.instance()
##	self.add_child(hitbox_instance)
##	# Rotates the points
##	if direction() == 1:
##		hitbox_instance.set_parameters(width, height, damage, angle,base_kb, kb_scaling, duration, type, points, angle_flipper, hitlag)
##	else:
##		var flip_x_points = Vector2(-points.x, points.y)
##		hitbox_instance.set_parameters(width, height, damage, -angle + 180, base_kb, kb_scaling, duration, type, flip_x_points, angle_flipper, hitlag)
##	return hitbox_instance

func create_hitbox(width, height, damage,angle,base_kb, kb_scaling,duration,type,points,angle_flipper,hitlag=1):
	var hitbox_instance = hitbox.instance()
	self.add_child(hitbox_instance)
	#Rotates The Points 
	if direction() == 1:
		hitbox_instance.set_parameters(width, height, damage,angle,base_kb, kb_scaling,duration,type,points,angle_flipper,hitlag)
	else:
		var flip_x_points = Vector2(-points.x, points.y)
		hitbox_instance.set_parameters(width, height, damage,-angle+180,base_kb, kb_scaling,duration,type,flip_x_points,angle_flipper,hitlag)
	return hitbox_instance

# A reference to the StateMachine node which is expected to be a child of this node.

# Increment the frame counter by one. This function should be called every game frame.
func updateframes(delta):
	frame += 1

# Flips the sprite horizontally based on the direction the character is facing.
func turn(direction):
	var dir = 0
	if direction:
		dir = -1
	else:
		dir = 1
	$Sprite.set_flip_h(direction)
	Ledge_Grab_F.set_cast_to(Vector2(dir*abs(Ledge_Grab_F.get_cast_to().x),Ledge_Grab_F.get_cast_to().y))
	Ledge_Grab_F.position.x = dir * abs(Ledge_Grab_F.position.x)
	Ledge_Grab_B.position.x = dir * abs(Ledge_Grab_B.position.x)
	Ledge_Grab_B.set_cast_to(Vector2(-dir*abs(Ledge_Grab_F.get_cast_to().x),Ledge_Grab_F.get_cast_to().y))

# Reset the frame counter to zero. Useful for restarting action durations.
func frame():
	frame = 0

func play_animation(animation_name):
	anim.play(animation_name)
# Initial setup when the node enters the scene tree.
func _ready():
	pass  # Currently does nothing, but this is where you would initialize any required setup.

# Updates every physics frame; used to update on-screen debug information.
func _physics_process(delta):
	$Frames.text = str(frame)  # Updates a node named "Frames" with the current frame count, used for debugging.
	selfState = states.text
	
	if position.y>800:
		get_tree().change_scene("res://MENU/MENU.tscn")


#attack
func STAB():
	if frame==10:
		create_hitbox(40,20,8,0,6,120,3,'normal',Vector2(65,-7.9),0,1)
	if frame >= 38:
		return true
		
		
