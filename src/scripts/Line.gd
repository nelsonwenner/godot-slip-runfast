class Line:
	
	var _border; var _runway; var _gramme; var _divid_line
	
	var _scale; var _curve; var _sprite_x
	
	var _world_x; var _world_y; var _world_z
	
	var _screen_x; var _screen_y; var _screen_w
	
	var _clip; var _sprite
	
	var _name_sprite
	
	func _init():
		self._world_x = 0
		self._world_y = 0
		self._world_z = 0
		self._screen_x = 0
		self._screen_y = 0
		self._screen_w = 0
		self._clip = 0
		self._scale = 0
		self._curve = 0
		self._sprite = 0
		self._sprite_x = 0
		
	
	func get_world_x():
		return self._world_x
		
		
	func get_world_y():
		return self._world_y
	
	
	func get_world_z():
		return self._world_z	
		
		
	func get_screen_x():
		return self._screen_x
		
		
	func get_screen_y():
		return self._screen_y
		
		
	func get_screen_w():
		return self._screen_w
		
		
	func get_scale():
		return self._scale
		
		
	func get_curve():
		return self._curve
		
		
	func get_sprite_x():
		return self._sprite_x
		
		
	func get_clip():
		return self._clip
	
	
	func get_sprite():
		return self._sprite	
	
	
	func set_world_z(value):
		self._world_z = value
	
	
	func set_world_x(value):
		self._world_x = value
		
		
	func set_world_y(value):
		self._world_y = value
		
		
	func set_screen_x(value):
		self._screen_x = value
		
		
	func set_screen_y(value):
		self._screen_y = value
		
		
	func set_screen_w(value):
		self._screen_w = value
		
		
	func set_scale(value):
		self._scale = value
		
		
	func set_curve(value):
		self._curve = value
		
		
	func set_sprite_x(value):
		self._sprite_x = value
		
		
	func set_clip(value):
		self._clip = value
	
	
	func set_sprite(value):
		self._sprite = value
		
		
	func set_name_sprite(value):
		self._name_sprite = value 
		
		
	func get_name_sprite():
		return self._name_sprite
		
	
	func get_color_border():
		return self._border
		
		
	func get_color_runway():
		return self._runway
		
	
	func get_color_gramme():
		return self._gramme
		
	
	func get_color_divid_line():
		return self._divid_line
		
		
	func set_color_border(value):
		self._border = value
		
		
	func set_color_runway(value):
		self._runway = value
		
		
	func set_color_gramme(value):
		self._gramme = value
		
		
	func set_color_divid_line(value):
		self._divid_line = value
		
		
	func screen_coordinates(cam_x, cam_y, cam_z, camera_depth, road_width, width, height):
		self._scale = camera_depth / ((self._world_z - cam_z) if (self._world_z - cam_z) > 0 else 0.01)
		self._screen_x = ((1 + self._scale * (self._world_x - cam_x)) * width / 2)
		self._screen_y = ((1 - self._scale * (self._world_y - cam_y)) * height / 2)
		self._screen_w = (self._scale * road_width * (width / 2))
		return self
	
	
	func run_sprite(width, height):
		
		var offsetX = self._screen_x + self._scale * self._sprite_x * 1920 / 2
		var offsetY = self._screen_y + 8
		var offsetW = width * self._screen_w / 266
		var offsetH = height * self._screen_w / 266
		
		offsetX += offsetW * self._sprite_x
		offsetY += offsetH * (-1)
		
		var clipH = offsetY + offsetH - self._clip
		
		if clipH < 0: clipH = 0
		
		self._sprite.position = Vector2(offsetX, offsetY)
		self._sprite.scale = Vector2(offsetW / width, offsetH / height)
		
		return self._sprite
