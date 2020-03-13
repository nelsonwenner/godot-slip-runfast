extends Node2D

onready var line = preload("res://src/scripts/Line.gd")

var WIDTH = 1920
var HEIGHT = 1080

export var RUNWAY_LENGHT = 1600
export var RUNWAY_WIDTH = 2000
export var SEGMENT_LENGHT = 200
export var CAMERA_DEPTH = 0.84

export var BORDER:Color
export var RUNWAY:Color
export var DIVID_LINE:Color
export var GRAMME:Color
export var STRIPED_RUNWAY:Color
export var STRIPED_BORDER:Color
export var STRIPED_DIVID_LINE:Color
export var STRIPED_GRAMME:Color

var NEW_BORDER:Color
var NEW_RUNWAY:Color
var NEW_DIVID_LINE:Color
var NEW_GRAMME:Color

var lines = []

var current_position = 0
var lines_lenght

var player_x = 0

var speed = 0

var up_is_pressed = false


func _ready():
	set_process_input(true)
	init()
	

func _process(delta): 
	update()
	
	
func _draw():
	controller_inputs()
	controller_position()
	
	var number_position = 0
	var start_point = (current_position / SEGMENT_LENGHT)
	var cam_horizontal = (1500 + lines[start_point].get_y())
	var max_y = HEIGHT
	var x = 0
	var distance_x = 0
	
	for n in range(start_point, start_point + 300):
		if (n >= lines_lenght): number_position = (lines_lenght * SEGMENT_LENGHT)
		else: number_position = 0
		
		var line_instance = lines[n%lines_lenght]
		var current_line = line_instance.screen_coordinates(player_x - x, cam_horizontal, current_position - number_position, CAMERA_DEPTH, RUNWAY_WIDTH, WIDTH, HEIGHT)
		
		var actual_position = lines[(n - 1) % lines_lenght]
		
		x += distance_x
		distance_x += current_line.get_curve()
		
		current_line.set_clip(max_y)
		
		if (current_line.get_Y() >= max_y): continue
		max_y = current_line.get_Y()
		
		add_colors(n)
		
		draw_runway(NEW_GRAMME, 0, actual_position.get_Y(), WIDTH, 0, current_line.get_Y(), WIDTH)
		draw_runway(NEW_BORDER, actual_position.get_X(), actual_position.get_Y(), actual_position.get_W() * 1.2, current_line.get_X(), current_line.get_Y(), current_line.get_W() * 1.2)
		draw_runway(NEW_RUNWAY, actual_position.get_X(), actual_position.get_Y(), actual_position.get_W(), current_line.get_X(), current_line.get_Y(), current_line.get_W())
		draw_runway(NEW_DIVID_LINE, actual_position.get_X(), actual_position.get_Y(), actual_position.get_W() * 0.02, current_line.get_X(), current_line.get_Y(), current_line.get_W() * 0.02)

	
func init():
	for index in range(RUNWAY_LENGHT):
		var struture_line = line.Line.new(0,0,0,0,0,0,0,0,0,0,0)
		
		lines.push_back(struture_line)
		lines[index].set_z(index * SEGMENT_LENGHT)
		
		controller_runway(index)
	lines_lenght = lines.size()
	set_process(true)
	

func controller_runway(index):
	if (index > 300 && index < 750): lines[index].set_curve(0.5)
	if (index > 800 && index < 1200): lines[index].set_curve(-0.7)
	if (index > 1200): lines[index].set_curve(0.2)


func draw_runway(color, x1, y1, w1, x2, y2, w2):
	var point = [Vector2(int(x1 - w1), int(y1)), Vector2(int(x2 - w2), int(y2)),
	Vector2(int(x2 + w2), int(y2)), Vector2(int(x1 + w1), int(y1))]
	draw_primitive(PoolVector2Array(point), PoolColorArray([color, color, color, color, color]), PoolVector2Array([]))


func controller_position():
	while current_position >= (lines_lenght * SEGMENT_LENGHT):
		current_position -= (lines_lenght * SEGMENT_LENGHT)
	while current_position < 0:
		current_position += (lines_lenght * SEGMENT_LENGHT)


func add_colors(n):
	if (n / 3) % 2:
		NEW_BORDER = BORDER
		NEW_RUNWAY = RUNWAY
	else:
		NEW_BORDER = STRIPED_BORDER
		NEW_RUNWAY = STRIPED_RUNWAY
	if (n / 9) % 2:
		NEW_DIVID_LINE = DIVID_LINE
		NEW_GRAMME = GRAMME
	else:
		NEW_DIVID_LINE = STRIPED_DIVID_LINE
		NEW_GRAMME = STRIPED_GRAMME


func controller_inputs():
	if up_is_pressed:
		speed += 3
		current_position += speed
		
		if speed >= 600: speed = 600
			
		if current_position == 320000:
			current_position = 0
		
		if Input.is_action_pressed("ui_right"):
			player_x += 200
		if Input.is_action_pressed("ui_left"):
			player_x -= 200
	
	elif speed > 5: 
		current_position += speed; speed -= 5
		if speed < 0: current_position = 0 


func _input(event):
    if event.is_action_pressed("ui_up"):
        up_is_pressed = true
    elif event.is_action_released("ui_up"):
        up_is_pressed = false


