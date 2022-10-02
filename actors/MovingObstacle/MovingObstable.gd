extends Node2D

signal kill_player

onready var sprite = $"%Sprite"
onready var path = $"%Path2D"
onready var path_follow = $"%PathFollow2D"

var texture
var moveable_area = Vector2(480 - 48, 350 - 48)
var player

var last_point = Vector2.ZERO
var min_distance_between_points = 96

var movement_speed = 12

func _ready():
	if texture != null:
		sprite.texture = texture
	
	sprite.scale = Vector2.ZERO
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE, .45)
	
	path.curve = Curve2D.new()
	path.curve.clear_points()
	
	for i in range(0, 2):
		_add_point_to_path()
	
	# make bounce loop
	path.curve.add_point(path.curve.get_point_position(0))

func _process(delta):
	path_follow.offset += movement_speed * delta

func set_texture(texture):
	self.texture = texture

func set_moveable_area(area):
	moveable_area = area

func set_movement_speed(movement_speed):
	self.movement_speed = movement_speed

func set_player(player):
	self.player = player

func _add_point_to_path():
	randomize()
	var point = _get_random_location()
	path.curve.add_point(point)
	
	print(point)
	
	last_point = point

func _get_random_location():
	var x = 0
	var y = 0
	var point = Vector2.ZERO
	
	for i in range(0, 100):
		x = rand_range(24, moveable_area.x)
		y = rand_range(24, moveable_area.y)
		
		point = Vector2(x, y)
		
		if point.distance_to(last_point) > min_distance_between_points and point.distance_to(player.position) > 64 + movement_speed:
			break
	
	return point

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("kill_player")
