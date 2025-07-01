# WaterArea.gd
extends Area3D

signal entered_water
signal exited_water

func _on_body_entered(body):
	if body.name == "Player":
		entered_water.emit()

func _on_body_exited(body):
	if body.name == "Player":
		exited_water.emit()
