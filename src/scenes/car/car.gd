extends Node2D


signal collision


func _on_body_area_entered(_area):
	emit_signal("collision")
