class Line:
	
	var _scale; var _curve; var _sprite_x
	
	var _x; var _y; var _z
	
	var _X; var _Y; var _W
	
	var _clip; var _sprite
	
	func _init(x, y, z, X, Y, W, scale, curve, sprite_x, clip, sprite):
		self._x = x
		self._y = y
		self._z = z
		self._X = X
		self._Y = Y
		self._W = W
		self._clip = clip
		self._scale = scale
		self._curve = curve
		self._sprite = sprite
		self._sprite_x = sprite_x
		
		
	func get_z():
		return self._z
	
	
	func get_x():
		return self._x
		
		
	func get_y():
		return self._y
		
		
	func get_X():
		return self._X
		
		
	func get_Y():
		return self._Y
		
		
	func get_W():
		return self._W
		
		
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
	
	
	func set_z(value):
		self._z = value
	
	
	func set_x(value):
		self._x = value
		
		
	func set_y(value):
		self._y = value
		
		
	func set_X(value):
		self._X = value
		
		
	func set_Y(value):
		self._Y = value
		
		
	func set_W(value):
		self._W = value
		
		
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
		
		
	func screen_coordinates(cam_x, cam_y, cam_z, camera_depth, road_width, width, height):
		self._scale = camera_depth / ((self._z - cam_z) if (self._z - cam_z) > 0 else 0.01)
		self._X = ((1 + self._scale * (self._x - cam_x)) * width / 2)
		self._Y = ((1 - self._scale * (self._y - cam_y)) * height / 2)
		self._W = (self._scale * road_width * (width / 2))
		return self
	
	
	func run_sprite():
		
		var offsetX = self._X + self._scale * self._sprite_x * 1920 / 2
		var offsetY = self._Y + 4
		var offsetW = 650 * self._W / 266
		var offsetH = 520 * self._W / 266
		
		offsetX += offsetW * self._sprite_x
		offsetY += offsetH * (-1)
		
		var clipH = offsetY + offsetH - self._clip
		
		if clipH < 0: clipH = 0
		
		self._sprite.position = Vector2(offsetX, offsetY)
		self._sprite.scale = Vector2(offsetW / 650, offsetH / 520)
		
		return self._sprite
