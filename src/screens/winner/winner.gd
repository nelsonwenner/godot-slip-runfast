extends Control


func _ready():
	$background/info.text = $background/info.text % [str(player_data.minutes), 
													str(player_data.seconds),
													str(player_data.minutes_step),
													str(player_data.seconds_step)]
	
