extends KinematicBody

var walk = 5
var run = 25
var gravity = -9.8
var acceleration
var deceleration
var velocity = Vector3()

var jumpStrength = 20
var terminalVelocity = 3
var left = Vector2()
var t_left = Vector2()
var right = Vector2()
var t_right = Vector2()
var grounded : bool
var view : Rect2
var cSize = 150


func _ready():
	view = get_viewport().get_visible_rect()
	initCursor($Cursor_L, $Cursor_R)
	pass

func _physics_process(delta):
	grounded = $GroundRay.is_colliding()
	Movement(delta)
	analogInput()
	Camera(left, right, delta)
	Cursors(left, right)
	
func _input(event):
	Jump()
	grapple()
	pass

func Movement(delta):
	var dir = WalkRun(delta)
	var grav = Gravity(delta)
	
	velocity.y += grav
	
	var hv = velocity
	hv.y = 0
	
	var new_pos = dir * run
	
	#Air Control
	if !grounded:
		acceleration = 0.1
		deceleration = 0.2
	#Ground Control
	else:
		acceleration = 2
		deceleration = 3
	var accel = deceleration
	if dir.dot(hv) > 0:
		accel = acceleration
	
	hv = hv.linear_interpolate(new_pos, accel * delta)
	
	velocity.x = hv.x
	velocity.z = hv.z
	move_and_slide(velocity, Vector3.UP)

func WalkRun(d):
	var speed = run # TODO: set walk vs run here
	var direction = Vector3.ZERO
	var basis = get_transform().basis
	
	if Input.is_action_pressed("i_left"):
		direction += basis.x
	if Input.is_action_pressed("i_right"):
		direction += -basis.x
	if Input.is_action_pressed("i_forward"):
		direction += basis.z
	if Input.is_action_pressed("i_back"):
		direction += -basis.z
	direction = direction.normalized()
	return direction
		
func Jump():
	if Input.is_action_just_pressed("i_jump") && grounded:
		velocity.y = jumpStrength
	
func Gravity(d):
	return gravity * d
	
func Camera(l, r, delta):
	var combined = l + r
	var h_speed = 1
	var v_speed = 5
	var springBackSpeed = 0.25
	var turnSpeed = 50
	var i = $Internal
	var target = $Internal/Forward

	# Horizontal
	rotate_y(-combined.x * h_speed * delta) #simple turning 
#	i.rotate_y(-combined.x * h_speed * delta)
#	i.rotation_degrees.y = i.rotation_degrees.y + (0 - i.rotation_degrees.y) * springBackSpeed * delta

	# Vertical
	target.translation.y = clamp(target.translation.y + combined.y * v_speed * delta, -10, 10)
	$Internal/Camera.look_at(target.get_global_transform().origin, Vector3.UP)

	# auto-turn
#	var turnTarget = transform.looking_at(i.get_transform().origin, Vector3.UP).basis.y.x - transform.basis.y.x
	#TODO: figure out correct approach
#	rotation_degrees.y = rotation_degrees.y + (i.rotation_degrees.y - rotation_degrees.y) * turnSpeed * delta
#	print(i.rotation_degrees.y,',', rotation_degrees.y,',', i.rotation_degrees.y - rotation_degrees.y)

func Cursors(l, r):
	var centering = cSize * 0.5
	var bounds = view.size
	var b_center = bounds.x * 0.5
	var yLimit = bounds.y * 0.5
	var xLimit = bounds.x * 0.25
	var leftStart = Vector2(xLimit, yLimit)
	var rightStart = Vector2(bounds.x * 0.75, yLimit)
	t_left = leftStart + (Vector2(l.x * b_center, -l.y * bounds.y * 0.75))
	t_right = rightStart + (Vector2(r.x * b_center, -r.y * bounds.y * 0.75))

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
	
func grapple():
	if Input.is_action_pressed("i_L_bumper"):
		var origin = $Internal/Camera.project_ray_origin(t_left)
		var vector = $Internal/Camera.project_ray_normal(t_left)		
		var l_cast = RayCast.new()
		l_cast.set_cast_to(vector - origin)
		l_cast.set_enabled(true)
		
		#drawline($Internal/Camera/g_left, $LeftHip.global_transform.origin, l_cast)
		$LeftHip.global_transform.origin = l_cast.get_collision_point()
		print(l_cast.get_collision_point())
	else:
		$LeftHip.global_transform = global_transform
		
	if Input.is_action_pressed("i_R_bumper"):
		print(t_right)

func drawline(grapple, a, b):
	grapple.clear()
	grapple.begin(Mesh.PRIMITIVE_LINES)
	grapple.set_color(Color(1, 0, 0, 1))
	grapple.add_vertex(a)
	grapple.add_vertex(b)
	grapple.end()