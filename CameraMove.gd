extends Camera3D

@export
var speed = 50

var pixelSize
var camSpeed
var real_translation

var mouseDelta = Vector3.ZERO

func _ready():
	pixelSize = (Vector2(size*2, size*2) / get_viewport().size.y)
	camSpeed = pixelSize * speed
	
	position = Vector3(snapped(position.x, pixelSize.x), position.y, snapped(position.z, pixelSize.y)).rotated(Vector3.UP, -PI/4)
	real_translation = position # real position is not snapped

func _process(delta):
	var velocity = Vector3.ZERO
	if (Input.is_action_pressed("ui_up")):
		velocity.z -= 1.5
	if (Input.is_action_pressed("ui_down")):
		velocity.z += 1.5
	if (Input.is_action_pressed("ui_left")):
		velocity.x -= 1
	if (Input.is_action_pressed("ui_right")):
		velocity.x += 1
	
	real_translation += (velocity * Vector3(camSpeed.x, 1, camSpeed.y) * delta)
	position = Vector3(
							snapped(real_translation.x, pixelSize.x), #x
							real_translation.y, #y
							snapped(real_translation.z, pixelSize.y) #z
					).rotated(Vector3.UP, PI/4)
