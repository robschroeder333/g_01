extends RigidBody

var walk = 3
var run = 3
var terminalVelocity = 3
var direction = Vector3()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _physics_process(delta):
	handleMovement(delta)
	
func handleMovement(d):
	var speed = run # TODO: set walk vs run here
	var grounded = $GroundRay.is_colliding()
	direction = Vector3(0,0,0)
	if grounded:
		if Input.is_action_pressed("ui_left"):
			direction.x += run
		if Input.is_action_pressed("ui_right"):
			direction.x -= run
		if Input.is_action_pressed("ui_up"):
			direction.z += run
		if Input.is_action_pressed("ui_down"):
			direction.z -= run
		apply_central_impulse(direction)
	if Input.is_action_just_pressed("ui_accept") && grounded:
		set_axis_velocity(Vector3(0,15,0))