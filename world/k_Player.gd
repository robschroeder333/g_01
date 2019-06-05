extends KinematicBody

var walk = 300
var run = 500
var gravity = 2
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
	direction = Vector3(0,0,0)
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	direction.y -= gravity 
	var movement = direction * d
	movement = applyTV(movement, d) * speed # make more like actual gravity
	move_and_slide(movement)
	
func applyTV(movement, d):
	var tv = terminalVelocity * d
	var positiveNegative = 0
	if abs(movement.y) > tv:
		if movement.y > 0: 
			positiveNegative = 1
		else:
			positiveNegative = -1 
		movement.y = tv * positiveNegative
	if abs(movement.x) > tv:
		if movement.x > 0: 
			positiveNegative = 1
		else:
			positiveNegative = -1 
		movement.x = tv * positiveNegative
	if abs(movement.z) > tv:
		if movement.z > 0: 
			positiveNegative = 1
		else:
			positiveNegative = -1 
		movement.z = tv * positiveNegative
	return movement
	
	
	
	