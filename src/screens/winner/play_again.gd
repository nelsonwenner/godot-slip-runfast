extends Button


func _on_play_again_button_up():
	player_data.reset()
	get_tree().change_scene("res://src/scenes/runway/runway.tscn")
