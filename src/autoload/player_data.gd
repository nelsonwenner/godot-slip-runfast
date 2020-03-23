extends Node


signal player_loser
signal player_winner


var losers:= 0 setget set_loser
var winner:= 0 setget set_winner

var minutes:= 0 setget set_minutes
var seconds:= 0 setget set_seconds

var minutes_step:= 0 setget set_minutes_step
var seconds_step:= 0 setget set_seconds_step


func reset():
	losers = 0
	winner = 0
	

func set_loser(state):
	losers = state
	emit_signal("player_loser")
	
	
func set_winner(state):
	winner = state
	emit_signal("player_winner")


func set_minutes(value):
	minutes = value
	
	
func set_seconds(value):
	seconds = value
	
	
func set_minutes_step(value):
	minutes_step = value
	
	
func set_seconds_step(value):
	seconds_step = value
	
