extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var texto = ""
	texto += "Draw calls: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	texto += "Vertices/Primitives: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
	texto += "Objetos en frame: %d\n" % Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	texto += "Nodos: %d\n" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	texto += "Memoria (MB): %.1f\n" % (Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0)
	
	text = texto
