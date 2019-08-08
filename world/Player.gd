extends RigidBody

var walk = 3
var run = 3
var terminalVelocity = 3
var direction = Vector3()
var left = Vector2()
var right = Vector2()
var grounded : bool
var view : Rect2
var cSize = 150

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	view = get_viewport().get_visible_rect()
	initCursor($Left,$Right)
	pass

func _physics_process(delta):
	grounded = $GroundRay.is_colliding()
	handleMovement(delta)
	analogInput()
	handleCamera(left, right)
	handleCursors(left, right)
	
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

func handleCursors(l, r):
	var centering = cSize * 0.5
	var c_Left = $Left
	var c_Right = $Right
	var bounds = view.size
	var b_center = bounds.x * 0.5
	var yLimit = bounds.y * 0.5
	var xLimit = bounds.x * 0.25
	var leftStart = Vector2(xLimit, yLimit)
	var rightStart = Vector2(bounds.x * 0.75, yLimit)
	var t_left = leftStart + (Vector2(l.x * b_center, -l.y * bounds.y * 0.75))
	var t_right = rightStart + (Vector2(r.x * b_center, -r.y * bounds.y * 0.75))
	
	t_left = Vector2(clamp(t_left.x, 0, b_center), clamp(t_left.y, 0, bounds.y))
	t_right = Vector2(clamp(t_right.x, b_center, bounds.x), clamp(t_right.y, 0, bounds.y))
	c_Left.rect_position = centerCursor(t_left, centering)
	c_Right.rect_position = centerCursor(t_right, centering)

func centerCursor(cursor, centering):
	cursor.x -= centering
	cursor.y -= centering
	return cursor
	
func initCursor(cL, cR):
	cL.rect_size = Vector2(cSize, cSize)
	cR.rect_size = Vector2(cSize, cSize)
	
func analogInput():
	left = Vector2(0,0)
	right = Vector2(0,0)
	left.x = Input.get_action_strength("i_L_right") - Input.get_action_strength("i_L_left")
	left.y = Input.get_action_strength("i_L_up") - Input.get_action_strength("i_L_down")
	right.x = Input.get_action_strength("i_R_right") - Input.get_action_strength("i_R_left")
	right.y = Input.get_action_strength("i_R_up") - Input.get_action_strength("i_R_down")