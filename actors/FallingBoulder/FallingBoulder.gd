extends Node2D

signal kill_player(boulder, player)

onready var fall_timer = $FallTimer
onready var sprite = $Sprite

var texture;

var movement_speed = 12
var seconds_before_fall = 1

var falling = false

func initialize(movement_speed, seconds_before_fall):
	self.movement_speed = movement_speed
	self.seconds_before_fall = seconds_before_fall

func set_texture(texture):
	self.texture = texture
	
	if sprite != null:
		sprite.texture = texture

func _ready():
	fall_timer.wait_time = seconds_before_fall
	fall_timer.one_shot = true
	fall_timer.start()
	
	if texture != null:
		sprite.texture = texture
	
func _process(delta):
	if not falling:
		return
	
	position.y += movement_speed * delta

func despawn():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, .45)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("kill_player", self, body)

func _on_FallTimer_timeout():
	falling = true
