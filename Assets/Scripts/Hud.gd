extends CanvasLayer

@onready var stats_label = $StatsLabel
@onready var coin_label = $CoinLabel

var coin_count: int = 0

func _process(_delta):
	var fps = Engine.get_frames_per_second()
	var obj_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	var rendered_objects = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var memory_mb = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)

	stats_label.text = "FPS: %d\nObjects: %d\nRendered: %d\nMemory: %.2f MB" % [
		fps, obj_count, rendered_objects, memory_mb
	]
	# Можно обновлять счёт монет в _process, но лучше обновлять только при изменении.
	# coin_label.text = "Coins: %d" % coin_count

func add_coin():
	coin_count += 1
	update_coin_label()

func update_coin_label():
	coin_label.text = "Coins: %d" % coin_count
