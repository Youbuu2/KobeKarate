extends StateMachine
onready var id = parent.id

func _ready():
	# Add various states to the state machine upon initialization.
	add_state('STAND')
	add_state('JUMP_SQUAT')
	add_state('SHORT_HOP')
	add_state('FULL_HOP')
	add_state('DASH')
	add_state('MOONWALK')
	add_state('WALK')
	add_state('CROUCH')
	add_state('AIR')
	add_state('LANDING')
	add_state('GROUND_ATTACK')
	add_state('STAB')
	add_state('HITSTUN')
	# Set the initial state to 'STAND' after all other ready processing is done.
	call_deferred("set_state", states.STAND)

func state_logic(delta):
	# Calls function to update frames based on the delta time and processes physics.
	parent.updateframes(delta)
	parent._physics_process(delta)

func get_transition(delta):
	# Applies movement physics with a potential snap to the ground.
	parent.move_and_slide_with_snap(parent.velocity * 2, Vector2.ZERO, Vector2.UP)
	# Display current state on parent's text node for debugging.
	if Landing() == true:
		parent.frame()
		return states.LANDING

	if Falling() == true:
		return states.AIR

	if Input.is_action_just_pressed("attack_%s" % id ) && ATTACK() == true: # add this when adding more attacks
		parent.frame()
		return states.GROUND_ATTACK

	# A match statement to handle transitions based on the current state and inputs.
	match state:
		states.STAND:
			if Input.is_action_just_pressed("jump_%s" % id):
				parent.frame()
				return states.JUMP_SQUAT

			# Handles input for moving right or left and transitions to 'DASH' state.
			if Input.get_action_strength("right_%s" % id) == 1:
				parent.velocity.x = parent.RUNSPEED
				parent.frame()
				parent.turn(false)
				return states.DASH
			if Input.get_action_strength("left_%s" % id) == 1:
				parent.velocity.x = -parent.RUNSPEED
				parent.frame()
				parent.turn(true)
				return states.DASH
			# Slows down the character when no input is detected (traction).
			if parent.velocity.x > 0 and state == states.STAND:
				parent.velocity.x += -parent.TRACTION * 1
				parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
			elif parent.velocity.x < 0 and state == states.STAND:
				parent.velocity.x += parent.TRACTION * 1
				parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
		# Placeholder for jump squat logic.
		states.JUMP_SQUAT:
			#pass
			if parent.frame == parent.jump_squat:
				if not Input.is_action_pressed("jump_%s" % id):
					parent.velocity.x = lerp(parent.velocity.x, 0, 0.08)
					parent.frame()
					return states.SHORT_HOP
				else:
					parent.velocity.x = lerp(parent.velocity.x, 0, 0.08)
					parent.frame()
					return states.FULL_HOP

		# Placeholder for short hop logic.
		states.SHORT_HOP:
			#pass
			parent.velocity.y = -parent.JUMPFORCE
			parent.frame()
			return states.AIR
		# Placeholder for full hop logic.
		states.FULL_HOP:
			#pass
			parent.velocity.y = -parent.MAX_JUMPFORCE
			parent.frame()
			return states.AIR
			
		# Handles dashing logic, checking for direction changes or stopping the dash.
		states.DASH:
			if Input.is_action_pressed("left_%s" % id):
				if parent.velocity.x > 0:
					parent.frame()
				parent.velocity.x = -parent.DASHSPEED
				parent.turn(true)
				if Input.is_action_just_pressed("jump_%s" % id): #and Input.is_action_pressed("shield"):
					parent.frame()
					return states.JUMP_SQUAT
			elif Input.is_action_pressed("right_%s" % id):
				if parent.velocity.x < 0:
					parent.frame()
				parent.velocity.x = parent.DASHSPEED
				parent.turn(false)
				if Input.is_action_just_pressed("jump_%s" % id): #and Input.is_action_pressed("shield"):
					parent.frame()
					return states.JUMP_SQUAT
			else:
				if parent.frame >= parent.dash_duration - 1:
					return states.STAND
		# Placeholder for moonwalk logic.
		states.MOONWALK:
			pass
		# Placeholder for walking logic.
		states.WALK:
			pass
		# Placeholder for crouch logic.
		states.CROUCH:
			pass
		states.AIR:
			AIRMOVEMENT()
		
		#ground attack logic
		states.GROUND_ATTACK:
			if Input.is_action_pressed("attack_%s" % id):
				parent.frame()
				return states.STAB

#STAB STATE
		states.STAB:
			if parent.frame == 0:
				parent.STAB()
				pass
			if parent.frame >= 1:
				if parent.velocity.x>0:
					parent.velocity.x += -parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
				elif parent.velocity.x <0:
					parent.velocity.x += parent.TRACTION*3
					parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			if parent.STAB()==true:
					parent.frame()
					return states.STAND


#HITSTUN STATE
		states.HITSTUN:
			if parent.knockback >= 3:
				var bounce = parent.move_and_collide(parent.velocity *delta) #can bounce off surfaces
				if bounce:
					parent.velocity = parent.velocity.bounce(bounce.normal) * .8
					parent.hitstun = round(parent.hitstun * .8)
			if parent.velocity.y < 0:
				parent.velocity.y +=parent.verticleDecay*0.5 * Engine.time_scale
				parent.velocity.y = clamp(parent.velocity.y,parent.velocity.y,0)
			if parent.velocity.x < 0:
				parent.velocity.x += (parent.horizontalDecay)*0.4 *-1 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x,parent.velocity.x,0)
			elif parent.velocity.x > 0:
				parent.velocity.x -= parent.horizontalDecay*0.4 * Engine.time_scale
				parent.velocity.x = clamp(parent.velocity.x,0,parent.velocity.x)
			if parent.frame == parent.hitstun:
				if parent.knockback >= 24:
					parent.frame()
					return states.AIR
				else:
					parent.frame()
					return states.AIR
			elif parent.frame >60*5:
				return states.AIR




#LANDING STATE
		states.LANDING:
			if parent.frame <= parent.landing_frames + parent.lag_frames: #checks whether or not the parents frame is less than or equal to landing frames plus lag frames
				if parent.frame == 1:
					pass
				if parent.velocity.x > 0:
					parent.velocity.x = parent.velocity.x - parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x, 0, parent.velocity.x)
				elif parent.velocity.x < 0:
					parent.velocity.x += parent.velocity.x + parent.TRACTION/2
					parent.velocity.x = clamp(parent.velocity.x, parent.velocity.x, 0)
				if Input.is_action_just_pressed("jump_%s" % id): #and Input.is_action_pressed("shield"):
					parent.frame()
					return states.JUMP_SQUAT
			else:
				if Input.is_action_pressed("down_%s" % id):
					parent.lag_frames = 0
					parent.frame()
					return states.CROUCH
				else:
					parent.frame()
					parent.lag_frames = 0
					return states.STAND
				parent.lag_frames = 0


func enter_state(new_state, old_state):
	match new_state:
		states.STAND:
			parent.play_animation('Idle')
			parent.states_text = str('STAND')
		states.DASH:
			parent.play_animation('walk')
			parent.states_text = str('DASH')
		states.JUMP_SQUAT:
			parent.play_animation('Idle')
			parent.states_text = str('JUMP_SQUAT')
		states.SHORT_HOP:
			parent.play_animation('Idle')
			parent.states_text = str('SHORT_HOP')
		states.FULL_HOP:
			parent.play_animation('Idle')
			parent.states_text = str('FULL_HOP')
		states.AIR:
			parent.play_animation('Idle')
			parent.states_text = str('AIR')
		states.LANDING:
			parent.play_animation('Idle')
			parent.states_text = str('LANDING')
		states.HITSTUN:
			parent.play_animation('Hit')
			parent.states_text = str('HIT')
		states.STAB:
			parent.play_animation('Attack')
			parent.states.text = str ('STAB')


func exit_state(old_state, new_state):
	# Function to handle any cleanup when exiting a state.
	pass

func state_includes(state_array):
	# Helper function to check if the current state is in a given array of states.
	for each_state in state_array:
		if state == each_state:
			return true
	return false

func AIRMOVEMENT():
	if parent.velocity.y < parent.FALLINGSPEED:
		parent.velocity.y +=parent.FALLSPEED
	if Input.is_action_pressed("down_%s" % id) and parent.velocity.y > -150 and not parent.fastfall :
		parent.velocity.y = parent.MAXFALLSPEED
		parent.fastfall = true
	if parent.fastfall == true:
		parent.set_collision_mask_bit(2,false)
		parent.velocity.y = parent.MAXFALLSPEED
		
	if  abs(parent.velocity.x) >=  abs(parent.MAXAIRSPEED):
		if parent.velocity.x > 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x += -parent.AIR_ACCEL
			elif Input.is_action_pressed("right_%s" % id):
					parent.velocity.x = parent.velocity.x
		if parent.velocity.x < 0:
			if Input.is_action_pressed("left_%s" % id):
				parent.velocity.x = parent.velocity.x
			elif Input.is_action_pressed("right_%s" % id):
				parent.velocity.x += parent.AIR_ACCEL
					
				
	elif abs(parent.velocity.x) < abs(parent.MAXAIRSPEED):
		if Input.is_action_pressed("left_%s" % id):
			parent.velocity.x += -parent.AIR_ACCEL*25
		if Input.is_action_pressed("right_%s" % id):
			parent.velocity.x += parent.AIR_ACCEL*25
		
	if not Input.is_action_pressed("left_%s" % id) and not Input.is_action_pressed("right_%s" % id):
		if parent.velocity.x < 0:
			parent.velocity.x += parent.AIR_ACCEL/ 5
		elif parent.velocity.x > 0:
			parent.velocity.x += -parent.AIR_ACCEL / 5

func Landing():
	if state_includes([states.AIR]):
		if (parent.GroundL.is_colliding()) and parent.velocity.y > 0:
			var collider = parent.GroundL.get_collider()
			parent.frame = 0
			if parent.velocity.y > 0:
				parent.velocity.y = 0
				parent.fastfall = false
				return true
				
		elif parent.GroundR.is_colliding() and parent.velocity.y > 0:
			var collider2 = parent.GroundR.get_collider()
			parent.frame = 0
			if parent.velocity.y >= 0:
				parent.velocity.y = 0
				parent.fastfall = false
				return true

func Falling():
	if state_includes([states.STAND,states.DASH]):
		if not parent.GroundL.is_colliding() and not parent.GroundR.is_colliding():
			return true

func ATTACK():
	if state_includes([states.STAND,states.DASH]):
		return true



