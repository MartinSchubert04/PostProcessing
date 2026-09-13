extends Label

var lastTime = 0.0
@export var player: Node3D
var pre_text = "FPS: 0"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0
	if now -  lastTime > 1.0:
		pre_text = "FPS: %s\n" % Engine.get_frames_per_second()
		lastTime = now
	
	text = pre_text + "X: %.1f Y: %.1f Z: %.1f" % [
			player.position.x,
			player.position.y,
			player.position.z
		]
