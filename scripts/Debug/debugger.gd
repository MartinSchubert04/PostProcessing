extends CanvasLayer

@onready var player: Node3D = %Player
var acum = 0.0
const INTERVAL = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	acum += delta
	if acum >= INTERVAL:
		acum = 0.0
		update_stats()

func update_stats():
	$PanelContainer/VBoxContainer/PlayerData.text = "Player   X:%.1f  Y:%.1f  Z:%.1f\n" % [
			player.position.x,
			player.position.y,
			player.position.z
		]

	$PanelContainer/VBoxContainer/Performance.text = "FPS: %d\n" % Performance.get_monitor(Performance.TIME_FPS)
	$PanelContainer/VBoxContainer/Performance.text += "Draw calls: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	$PanelContainer/VBoxContainer/Performance.text += "Vertices/Primitives: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	$PanelContainer/VBoxContainer/Performance.text  += "Objetos en frame: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	$PanelContainer/VBoxContainer/Performance.text  += "Nodos: %d\n" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	$PanelContainer/VBoxContainer/Performance.text  += "Memoria (MB): %.1f\n" % (Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0)

func _input(event):
	if event.is_action_pressed("toggle_debug"):
		visible = !visible
