extends Button


func _on_retry_button_up():
	print("oii")
	get_tree().paused = false
	get_tree().reload_current_scene()
