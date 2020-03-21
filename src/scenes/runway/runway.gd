extends Node2D

onready var billboard_01 = preload("res://src/scenes/runway_objects/billboard_01.tscn")
onready var road_block = preload("res://src/scenes/runway_objects/road_block.tscn")
onready var tree_01 = preload("res://src/scenes/runway_objects/tree_01.tscn")
onready var tree_02 = preload("res://src/scenes/runway_objects/tree_02.tscn")
onready var bush_01 = preload("res://src/scenes/runway_objects/bush_01.tscn")
onready var line = preload("res://src/scripts/Line.gd")

var WIDTH = 1920
var HEIGHT = 1080

export var RUNWAY_LENGHT = 2800
export var RUNWAY_WIDTH = 2500
export var SEGMENT_LENGHT = 400
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

var up_is_pressed = false

var controller_draw_sprites = true

var speed = 0
var max_speed = 720
var centrifugal = 0.00009

var accumulate_curve = 0
var distance_x = 0

enum State {
	tree_01 = 1, 
	tree_02 = 2, 
	bush_01 = 3,
	billboard_01 = 4,
	road_block = 5
}

var current_state = State.tree_01

var play_curve = 0

var skyline

func _ready():
	randomize()
	
	$car.position = Vector2(960, 900)
	skyline = get_node("../skyline/Sprite")
	
	set_process_input(true)
	init()
	

func _process(_delta): 
	update()
	
	
func _draw():
	
	var speed_percent = speed / 500
	
	controller_inputs()
	controller_curve(speed_percent)
	controller_position()
	
	var start_point = (current_position / SEGMENT_LENGHT)
	var cam_horizontal = (1800 + lines[start_point].get_world_y())
	var max_y = HEIGHT
	
	accumulate_curve  = 0
	distance_x = 0
	
	controller_skyline(start_point)
	
	for n in range(start_point, start_point + 300):
	
		var line_instance = lines[n%lines_lenght]
	
		var current_line = line_instance.screen_coordinates(($car.position.x - 960) - accumulate_curve, cam_horizontal, (start_point * SEGMENT_LENGHT) - (lines_lenght * SEGMENT_LENGHT if n >= lines_lenght else 0), CAMERA_DEPTH, RUNWAY_WIDTH, WIDTH, HEIGHT)
		
		var previous_line = lines[(n - 1) % lines_lenght]
		
		var player_position_horizontal = play_curve - current_line.get_curve()
		
		if player_position_horizontal <= -35 || player_position_horizontal >= 35:
			pass
			#print("fora da pista")
			#speed -= 3
		
		accumulate_curve += distance_x
		distance_x += current_line.get_curve()
		
		current_line.set_clip(max_y)
		
		if (current_line.get_screen_y() >= max_y): continue
		max_y = current_line.get_screen_y()
		
		#add_colors(n)
		
		render_polygon(current_line.get_color_gramme(), 0, previous_line.get_screen_y(), WIDTH, 0, current_line.get_screen_y(), WIDTH)
		render_polygon(current_line.get_color_border(), previous_line.get_screen_x(), previous_line.get_screen_y(), previous_line.get_screen_w() * 1.1, current_line.get_screen_x(), current_line.get_screen_y(), current_line.get_screen_w() * 1.1)
		render_polygon(current_line.get_color_runway(), previous_line.get_screen_x(), previous_line.get_screen_y(), previous_line.get_screen_w(), current_line.get_screen_x(), current_line.get_screen_y(), current_line.get_screen_w())
		render_polygon(current_line.get_color_divid_line(), previous_line.get_screen_x(), previous_line.get_screen_y(), previous_line.get_screen_w() * 0.02, current_line.get_screen_x(), current_line.get_screen_y(), current_line.get_screen_w() * 0.02)
	
	draw_sprites()
	update_position_sprites(start_point)
	

func init():
	for index in range(RUNWAY_LENGHT):
		var struture_line = line.Line.new()
		
		lines.push_back(struture_line)
		add_colors(index)
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


func controller_skyline(start_point):
	if speed > 500 || speed < -500:
		if speed > 0:
			skyline.position -= Vector2(lines[start_point].get_curve() * 1, 0)
		if speed < 0:
			skyline.position += Vector2(lines[start_point].get_curve() * 1, 0)
	

func draw_sprites():
	if controller_draw_sprites:
		for i in range(lines_lenght):
			var current = lines[i]
			if current.get_sprite():
				set_state_sprite(current.get_name_sprite())

				match current_state:
					State.tree_01:
						add_child(current.run_sprite(650, 520))
					State.tree_02:
						add_child(current.run_sprite(650, 520))
					State.bush_01:
						add_child(current.run_sprite(350, 100))
					State.billboard_01:
						add_child(current.run_sprite(650, 520))
					State.road_block:
						add_child(current.run_sprite(40, 1))
	controller_draw_sprites = false


func update_position_sprites(start_point):
	var aux = start_point + 300
	while aux > start_point:
		var current = lines[aux%lines_lenght]
		if current.get_sprite():
			set_state_sprite(current.get_name_sprite())

			match current_state:
				State.tree_01:
					current.run_sprite(650, 520)
				State.tree_02:
					current.run_sprite(650, 520)
				State.bush_01:
					current.run_sprite(350, 100)
				State.billboard_01:
					current.run_sprite(650, 520)
				State.road_block:
					current.run_sprite(40, 1)
		aux -= 1


func set_state_sprite(state):
	current_state = state


func controller_position():
	while current_position >= (lines_lenght * SEGMENT_LENGHT):
		current_position -= (lines_lenght * SEGMENT_LENGHT)
	while current_position < 0:
		current_position += (lines_lenght * SEGMENT_LENGHT)


func controller_inputs():
	
	$car/body/AnimatedSprite.play("idle")
	
	if up_is_pressed:
		
		if Input.is_action_pressed("ui_right"):
			$car/body/AnimatedSprite.play("curve_right")
			$car.position.x += 25
			play_curve += 1
			
		if Input.is_action_pressed("ui_left"):
			$car/body/AnimatedSprite.play("curve_left")
			$car.position.x -= 25
			play_curve -= 1
			
		if Input.is_action_pressed("ui_home"):
			
			if accumulate_curve > 100000 && speed > 500:
				$car/body/AnimatedSprite.play("slip_right")
				$car.position.x += 15
				
			elif accumulate_curve < -100000 && speed > 500:
				$car/body/AnimatedSprite.play("slip_left")
				$car.position.x -= 15
				
		speed += 5
	else:
		speed -= 5
	
	speed = clamp(speed, 0, max_speed)
	current_position += speed
	

func controller_curve(speed_percent):
	if accumulate_curve > 10000:
		$car.position.x -= (speed_percent * accumulate_curve * centrifugal)
		
	if accumulate_curve < -10000:
		$car.position.x -= (speed_percent * (accumulate_curve / 2) * centrifugal)
		
	camera_x = clamp(camera_x, -3000, 3000)
	
	$car.position.x = clamp($car.position.x, 95, WIDTH - 95)


func add_colors(index):
	if (index / 3) % 2:
		lines[index].set_color_border(BORDER)
		lines[index].set_color_runway(RUNWAY)
	else:
		lines[index].set_color_border(STRIPED_BORDER)
		lines[index].set_color_runway(STRIPED_RUNWAY)
		
	if (index / 9) % 2:
		lines[index].set_color_divid_line(DIVID_LINE)
		lines[index].set_color_gramme(GRAMME)
	else:
		lines[index].set_color_divid_line(STRIPED_DIVID_LINE)
		lines[index].set_color_gramme(STRIPED_GRAMME)
	
	if index > 10 && index < 15:
		lines[index].set_color_runway(Color(204, 204, 204))
		lines[index].set_color_divid_line(Color(204, 204, 204))


func controller_runway(index):
	
	var curves = {
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
	
	#var instance_tree_01 = tree_01.instance()
	#var instance_tree_02 = tree_02.instance()
	#var instance_bush_01 = bush_01.instance()
	#var instance_billboard_01 = billboard_01.instance()
	var instance_road_block = road_block.instance()
	
	if (index > 200 && index % 150 == 0):
		lines[index].set_name_sprite(5)
		lines[index].set_sprite(instance_road_block)
		lines[index].set_sprite_x(rand_range(-5, 5))
	
	"""
	if (index > 20 && index < 600 && index % 10 == 0):
		lines[index].set_name_sprite(1)
		lines[index].set_sprite(instance_tree_01)
		lines[index].set_sprite_x(-0.5)
		
	if (index > 800 && index % 10 == 0):
		lines[index].set_name_sprite(1)
		lines[index].set_sprite(instance_tree_01)
		lines[index].set_sprite_x(1)
	

	if (index > 500 && index % 15 == 0):
		lines[index].set_name_sprite(2)
		lines[index].set_sprite(new_tree_02)
		lines[index].set_sprite_x(rand_range(2, 5))
	"""
	
	# Curve on right
	
	if (index > 50 && index < 150): lines[index].set_curve(curves.CURVE_RIGHT01)
	if (index > 150 && index < 250): lines[index].set_curve(curves.CURVE_RIGHT02)
	if (index > 250 && index < 350): lines[index].set_curve(curves.CURVE_RIGHT03)
	if (index > 350 && index < 550): lines[index].set_curve(curves.CURVE_RIGHT05)
	if (index > 550 && index < 650): lines[index].set_curve(curves.CURVE_RIGHT06)
	
	# Curve on left
	
	if (index > 650 && index < 1000): lines[index].set_curve(curves.CURVE_LEFT04)
	if (index > 1000 && index < 1200): lines[index].set_curve(curves.CURVE_LEFT05)
	if (index > 1200 && index < 1400): lines[index].set_curve(curves.CURVE_RIGHT06)
	
	# Curve on right
	
	if (index > 1400 && index < 1600): lines[index].set_curve(curves.CURVE_RIGHT03)
	if (index > 1600 && index < 1800): lines[index].set_curve(curves.CURVE_RIGHT05)
	
	# Curve on left
	
	if (index > 1800 && index < 2000): lines[index].set_curve(curves.CURVE_LEFT03)
	if (index > 2000 && index < 2200): lines[index].set_curve(curves.CURVE_LEFT05)
	
	# Curve on right
	
	if (index > 2200 && index < 2400): lines[index].set_curve(curves.CURVE_RIGHT05)
	if (index > 2400 && index < 2600): lines[index].set_curve(curves.CURVE_RIGHT06)
	
	# Curve on left
	
	if (index > 2600 && index < 2800): lines[index].set_curve(curves.CURVE_LEFT05)
	if (index > 3000): lines[index].set_curve(curves.CURVE_LEFT06)
	
	
func _on_car_collision():
	current_position += -1000
	speed = 0
