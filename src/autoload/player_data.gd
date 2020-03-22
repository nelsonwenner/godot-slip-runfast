extends Node


signal player_loser
signal player_winner


var losers:= 0 setget set_loser
var winner:= 0 setget set_winner


func reset():
	losers = 0
	winner = 0
	

func set_loser(state):
	losers = state
	emit_signal("player_loser")
	
	
func set_winner(state):
	winner = state
	emit_signal("player_winner")
