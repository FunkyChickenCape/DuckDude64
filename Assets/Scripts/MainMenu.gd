extends Control

@onready var button_start = $Button_Start
@onready var button_exit = $Button_Exit

func _ready():
	button_start.pressed.connect(on_start_pressed)
	button_exit.pressed.connect(on_exit_pressed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func on_start_pressed():
	# Загружаем сцену с игрой (замени "res://GameScene.tscn" на свою игровую сцену)
	get_tree().change_scene_to_file("res://Assets/Scenes/Scene_1.tscn")


func on_exit_pressed():
	get_tree().quit()
 
