extends CanvasLayer

@onready var stats_label = $StatsLabel

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	var obj_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	var rendered_objects = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)

	stats_label.text = "FPS: %d\nObjects: %d\nRendered: %d\nMemory: %.2f MB" % [
		fps, obj_count, rendered_objects, memory_mb
	]
