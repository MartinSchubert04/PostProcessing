extends SpringArm3D

@export var height_offset = 1.2
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export_range(0.0, 90.0) var tilt_limit = 70.0
@export_range(0.0, 1.0) var damping = 0.1

var following: Node3D
var x_target = 0.0
var y_target = 0.0
var zoom_min = 1.5
var zoom_max = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(height_offset)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = following.global_position + Vector3(0, height_offset, 0)
	
	rotation.x = lerp_angle(rotation.x, x_target, damping)
	rotation.y = lerp_angle(rotation.y, y_target, damping)

	var tilt_radians = deg_to_rad(tilt_limit)
	rotation.x = clamp(rotation.x, -tilt_radians, tilt_radians)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		y_target += -event.relative.x * mouse_sensitivity
		x_target += -event.relative.y * mouse_sensitivity
		
	if event is InputEventMouseButton and event.pressed:
		if event.is_action_pressed("zoom_in") and spring_length > zoom_min:
			spring_length -= 1
		if event.is_action_pressed("zoom_out") and spring_length < zoom_max:
			spring_length += 1
		
func set_following(target: Node3D):
	if following != null:
		remove_excluded_object(following)
			
	following = target
	add_excluded_object(target)
