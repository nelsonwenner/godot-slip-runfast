extends Node2D

onready var tree_01 = preload("res://src/scenes/runway_objects/tree_01.tscn")
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

var camera_x = 0

var speed = 0

var up_is_pressed = false

var controller_draw_sprites = true

var max_speed = 520

var accumulate_curve = 0
var distance_x = 0


func _ready():
	set_process_input(true)
	init()
	

func _process(_delta): 
	update()
	
	
func _draw():
	controller_inputs()
	controller_position()
	
	var number_position = 0
	var start_point = (current_position / SEGMENT_LENGHT)
	var cam_horizontal = (1800 + lines[start_point].get_world_y())
	var max_y = HEIGHT
	
	accumulate_curve  = 0
	distance_x = 0
	
	for n in range(start_point, start_point + 300):
		if (n >= lines_lenght): number_position = (lines_lenght * SEGMENT_LENGHT)
		else: number_position = 0
		
		var line_instance = lines[n%lines_lenght]
		var current_line = line_instance.screen_coordinates(camera_x - accumulate_curve, cam_horizontal, current_position - number_position, CAMERA_DEPTH, RUNWAY_WIDTH, WIDTH, HEIGHT)
		
		var previous_line = lines[(n - 1) % lines_lenght]
		
		accumulate_curve  += distance_x
		distance_x += current_line.get_curve()
		
		current_line.set_clip(max_y)
		
		if (current_line.get_screen_y() >= max_y): continue
		max_y = current_line.get_screen_y()
		
		add_colors(n)
		
		render_polygon(NEW_GRAMME, 0, previous_line.get_screen_y(), WIDTH, 0, current_line.get_screen_y(), WIDTH)
		render_polygon(NEW_BORDER, previous_line.get_screen_x(), previous_line.get_screen_y(), previous_line.get_screen_w() * 1.2, current_line.get_screen_x(), current_line.get_screen_y(), current_line.get_screen_w() * 1.2)
		render_polygon(NEW_RUNWAY, previous_line.get_screen_x(), previous_line.get_screen_y(), previous_line.get_screen_w(), current_line.get_screen_x(), current_line.get_screen_y(), current_line.get_screen_w())
		render_polygon(NEW_DIVID_LINE, previous_line.get_screen_x(), previous_line.get_screen_y(), previous_line.get_screen_w() * 0.02, current_line.get_screen_x(), current_line.get_screen_y(), current_line.get_screen_w() * 0.02)
	
	draw_sprites()
	update_position_sprites(start_point)
	

func init():
	for index in range(RUNWAY_LENGHT):
		var struture_line = line.Line.new(0,0,0,0,0,0,0,0,0,0,0)
		
		lines.push_back(struture_line)
		lines[index].set_world_z(index * SEGMENT_LENGHT)
		
		controller_runway(index)
	lines_lenght = lines.size()
	set_process(true)
	
	
func _input(event):
    if event.is_action_pressed("ui_up"):
        up_is_pressed = true
    elif event.is_action_released("ui_up"):
        up_is_pressed = false


func render_polygon(color, x1, y1, w1, x2, y2, w2):
	var point = [Vector2(int(x1 - w1), int(y1)), Vector2(int(x2 - w2), int(y2)),
	Vector2(int(x2 + w2), int(y2)), Vector2(int(x1 + w1), int(y1))]
	draw_primitive(PoolVector2Array(point), PoolColorArray([color, color, color, color, color]), PoolVector2Array([]))


func draw_sprites():
	if controller_draw_sprites:
		for i in range(lines_lenght):
			var current = lines[i]
			if current.get_sprite():
				add_child(current.run_sprite())
	controller_draw_sprites = false


func update_position_sprites(start_point):
	var aux = start_point + 300
	while aux > start_point:
		var current = lines[aux%lines_lenght]
		if current.get_sprite():
			current.run_sprite()
		aux -= 1


func controller_position():
	while current_position >= (lines_lenght * SEGMENT_LENGHT):
		current_position -= (lines_lenght * SEGMENT_LENGHT)
	while current_position < 0:
		current_position += (lines_lenght * SEGMENT_LENGHT)
		

func controller_inputs():
	if up_is_pressed:
		
		if Input.is_action_pressed("ui_right"):
			camera_x += 150
		if Input.is_action_pressed("ui_left"):
			camera_x -= 150
			
		speed += 2
	else:
		speed -= 5
		
	speed = clamp(speed, 0, max_speed)
	current_position += speed


func controller_runway(index):
	
	var curves = {
		CURVE_RIGHT00 = 1.5,
		CURVE_RIGHT01 = 2.5,
		CURVE_RIGHT02 = 3.5,
		CURVE_RIGHT03 = 4.5,
		CURVE_RIGHT04 = 5.5,
		CURVE_RIGHT05 = 6.5,
		CURVE_RIGHT06 = 7.5,
		
		CURVE_LEFT01 = -2.5,
		CURVE_LEFT02 = -3.5,
		CURVE_LEFT03 = -4.5,
		CURVE_LEFT04 = -5.5,
		CURVE_LEFT05 = -6.5,
		CURVE_LEFT06 = -7.5
	}
	
	var new_tree_01 = tree_01.instance()
	
	if (index > 100 && index < 400 && index % 20 == 0):
		lines[index].set_sprite_x(-0.5)
		lines[index].set_sprite(new_tree_01)
		
	if (index > 500 && index % 20 == 0):
		lines[index].set_sprite_x(1)
		lines[index].set_sprite(new_tree_01)
		
	if (index > 100 && index < 500): lines[index].set_curve(curves.CURVE_RIGHT01)
	if (index > 500 && index < 1100): lines[index].set_curve(curves.CURVE_RIGHT00)
	if (index > 1200): lines[index].set_curve(curves.CURVE_LEFT04)
	if (index > 1600): lines[index].set_curve(curves.CURVE_LEFT03)
	

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
