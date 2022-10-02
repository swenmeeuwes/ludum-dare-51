extends KinematicBody2D

onready var sprite = $Sprite

var movement_speed = 128
var screen_size = Vector2(480, 270)

func initialize(screen_size):
	self.screen_size = screen_size

func _process(delta):
	var movement_input = _get_movement_input()
	_move(movement_input * movement_speed * delta)

func _move(movement):
	move_and_collide(movement)
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

func _get_movement_input():
	var x = Input.get_axis("move_left", "move_right")
	var y = Input.get_axis("move_up", "move_down")
	
	if x != 0:
		sprite.flip_h = x < 0
	
	return Vector2(x, y)
