extends Node2D

var WIDTH = 1280
var HEIGHT = 720

export var RUNWAY_LENGHT = 1600
export var RUNWAY_WIDTH = 2000
export var SEGMENT_LENGHT = 200
export var CAMERA_DEPTH = 0.84
export var DIVIDE_LINE:int

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
	var cam_horizontal = (1500 + lines[start_point].y)
	var max_x = HEIGHT
	var x = 0
	var distance_x = 0
	
	for n in range(start_point, start_point + 300):
		if (n >= lines_lenght): number_position = (lines_lenght * SEGMENT_LENGHT)
		else: number_position = 0
		
		var current_line = screen_coordinates(lines[fmod(n, lines_lenght)], player_x - x, cam_horizontal, current_position - number_position)
		
		var actual_position = lines[fmod(n - 1, lines_lenght)]
		
		x += distance_x
		distance_x += current_line.curve
		
		if (current_line.Y >= max_x): continue
		max_x = current_line.Y
		
		add_colors(n)
		
		draw_runway(NEW_GRAMME, 0, actual_position.Y, WIDTH, 0, current_line.Y, WIDTH)
		draw_runway(NEW_BORDER, actual_position.X, actual_position.Y, actual_position.W * 1.2, current_line.X, current_line.Y, current_line.W * 1.2)
		draw_runway(NEW_RUNWAY, actual_position.X, actual_position.Y, actual_position.W, current_line.X, current_line.Y, current_line.W)
		draw_runway(NEW_DIVID_LINE, actual_position.X, actual_position.Y, actual_position.W * 0.01, current_line.X, current_line.Y, current_line.W * 0.01)

	
func init():
	for index in range(RUNWAY_LENGHT):
		var struture_line = {
			x = 0, y = 0, z = 0,
			X = 0, Y = 0, W = 0, 
			scale = 0, curve = 0,
		}
		lines.push_back(struture_line)
		lines[index].z = (index * SEGMENT_LENGHT)
		movements_controller_runway(index)
	lines_lenght = lines.size()
	set_process(true)
	

func movements_controller_runway(index):
	if (index > 300 && index < 750): lines[index].curve = 0.5
	if (index > 800 && index < 1200): lines[index].curve = -0.7
	if (index > 1200): lines[index].curve = 0.2


func screen_coordinates(struture_line, cam_x, cam_y, cam_z):
	struture_line.scale = CAMERA_DEPTH / ((struture_line.z - cam_z) if (struture_line.z - cam_z) > 0 else 0.01)
	struture_line.X = (1 + struture_line.scale * (struture_line.x - cam_x)) * WIDTH  / 2
	struture_line.Y = (1 - struture_line.scale * (struture_line.y - cam_y)) * HEIGHT / 2
	struture_line.W = struture_line.scale * RUNWAY_WIDTH * (WIDTH / 2)
	return struture_line


func draw_runway(col, x1, y1, w1, x2, y2, w2):
	var point = [Vector2(int(x1 - w1), int(y1)), Vector2(int(x2 - w2), int(y2)),
	Vector2(int(x2 + w2), int(y2)), Vector2(int(x1 + w1), int(y1))]
	draw_primitive(PoolVector2Array(point), PoolColorArray([col, col, col, col, col]), PoolVector2Array([]))


func controller_position():
	while current_position >= (lines_lenght * SEGMENT_LENGHT):
		current_position -= (lines_lenght * SEGMENT_LENGHT)
	while current_position < 0:
		current_position += (lines_lenght * SEGMENT_LENGHT)


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


func add_colors(n):
	if(fmod(n / 3, 2)):
		NEW_BORDER = BORDER
		NEW_RUNWAY = RUNWAY
	else:
		NEW_BORDER = STRIPED_BORDER
		NEW_RUNWAY = STRIPED_RUNWAY
	if (fmod(n / 9, 2)):
		NEW_DIVID_LINE = DIVID_LINE
		NEW_GRAMME = GRAMME
	else:
		NEW_DIVID_LINE = STRIPED_DIVID_LINE
		NEW_GRAMME = STRIPED_GRAMME


func _input(event):
    if event.is_action_pressed("ui_up"):
        up_is_pressed = true
    elif event.is_action_released("ui_up"):
        up_is_pressed = false


