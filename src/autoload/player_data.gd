extends Node


signal player_loser


var losers:= 0 setget set_loser


func reset():
	losers = 0


func set_loser(state):
	losers = state
	emit_signal("player_loser")
