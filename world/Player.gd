extends KinematicBody

var walk = 5
var run = 15
var gravity = 5
var jumpStrength = 50
var terminalVelocity = 3
var direction = Vector3()
var left = Vector2()
var right = Vector2()
var grounded : bool
var view : Rect2
var cSize = 150

func _ready():
	view = get_viewport().get_visible_rect()
	initCursor($Cursor_L, $Cursor_R)
	pass

func _physics_process(delta):
	grounded = $GroundRay.is_colliding()
	handleMovement()
	analogInput()
	handleCamera(left, right, delta)
	handleCursors(left, right)

func handleMovement():
	direction = Vector3(0,0,0)
	direction += handleRun()
#	direction += handleJump()
	direction += handleGravity()
	move_and_slide(direction)

func handleRun():
	var speed = run # TODO: set walk vs run here
	direction = Vector3(0,0,0)
	if grounded:
		if Input.is_action_pressed("i_left"):
			direction.x += 1
		if Input.is_action_pressed("i_right"):
			direction.x -= 1
		if Input.is_action_pressed("i_forward"):
			direction.z += 1
		if Input.is_action_pressed("i_back"):
			direction.z -= 1
		# TODO: needs to adjust to local rotation
		direction = direction.normalized()
		direction *= run
	return direction
		
func handleJump():
	if Input.is_action_just_pressed("i_jump") && grounded:
		return Vector3.UP * jumpStrength
	return Vector3.ZERO
	
func handleGravity():
	if !grounded:
		return Vector3(0, -gravity, 0)
	return Vector3.ZERO
	
func handleCamera(l, r, delta):
	var combined = l + r
	var h_speed = 0.1
	var v_speed = 5
	var springBackSpeed = 0.5
	var turnSpeed = 30
	var i = $Internal
	var target = $Internal/Forward

	#Handle Horizontal
	i.rotate_y(-combined.x * h_speed * delta)
	i.rotation_degrees.y = i.rotation_degrees.y + (0 - i.rotation_degrees.y) * springBackSpeed *2 * delta

	#Handle Vertical
	target.translation.y = clamp(target.translation.y + combined.y * v_speed * delta, -10, 10)
	$Internal/Camera.look_at(target.get_global_transform().origin, Vector3.UP)

	#Handle auto-turn
	var turnTarget = transform.looking_at(i.get_transform().origin, Vector3.UP).basis.y.x - transform.basis.y.x
	print(i.rotation_degrees.y)
	#TODO: figure out correct approach
#	rotation_degrees.y = rotation_degrees.y + (i.rotation_degrees.y - rotation_degrees.y) * springBackSpeed *2 * delta
#	rotate_y(i.rotation_degrees.y * springBackSpeed * delta)


func handleCursors(l, r):
	var centering = cSize * 0.5
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
	$Cursor_L.rect_position = centerCursor(t_left, centering)
	$Cursor_R.rect_position = centerCursor(t_right, centering)

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