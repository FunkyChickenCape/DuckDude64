extends Area3D

@export var rotate_speed: float = 90.0           # градусов в секунду
@export var float_amplitude: float = 0.2         # амплитуда плавания
@export var float_speed: float = 2.0             # скорость плавания
@export var pickup_sound: AudioStreamPlayer3D    # опционально

var start_y: float
var time: float = 0.0


func _ready():
	start_y = global_position.y
	play_animation()

func play_animation():
	# ничего не нужно, если вращаем вручную
	pass

func _process(delta):
	# Вращение по оси Y
	rotate_y(deg_to_rad(rotate_speed) * delta)

	# Плавание вверх-вниз (синус)
	time += delta
	var float_offset = sin(time * float_speed) * float_amplitude
	var pos = global_position
	pos.y = start_y + float_offset
	global_position = pos

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Найти HUD в дереве сцены (замени путь, если у тебя другой)
		var hud = get_tree().get_root().get_node("Main/Hud")  
		if hud and hud.has_method("add_coin"):
			hud.add_coin()
		queue_free()  # Удаляем монетку, она подобрана
