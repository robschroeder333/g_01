extends RigidBody

var walk = 3
var run = 3
var terminalVelocity = 3
var direction = Vector3()
var left = Vector2()
var right = Vector2()
var grounded

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	grounded = $GroundRay.is_colliding()
	handleMovement(delta)
	analogInput()
	
func handleMovement(d):
	var speed = run # TODO: set walk vs run here
	direction = Vector3(0,0,0)
	if grounded:
		if Input.is_action_pressed("i_left"):
			direction.x += run
		if Input.is_action_pressed("i_right"):
			direction.x -= run
		if Input.is_action_pressed("i_forward"):
			direction.z += run
		if Input.is_action_pressed("i_back"):
			direction.z -= run
		apply_central_impulse(direction)
	if Input.is_action_just_pressed("i_jump") && grounded:
		set_axis_velocity(Vector3(0,15,0))
		
func handleCamera(l, r):
	var combined = l + r
	# TODO: log testing

func analogInput():
	left = Vector2(0,0)
	right = Vector2(0,0)
	left.x = Input.get_action_strength("i_L_right") - Input.get_action_strength("i_L_left")
	left.y = Input.get_action_strength("i_L_up") - Input.get_action_strength("i_L_down")
	right.x = Input.get_action_strength("i_R_right") - Input.get_action_strength("i_R_left")
	right.y = Input.get_action_strength("i_R_up") - Input.get_action_strength("i_R_down")