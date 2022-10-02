extends Sprite

onready var duration_timer = $DurationTimer

var pulse_tween: SceneTreeTween

func show_warning(duration):
	scale = Vector2.ZERO
	
	duration_timer.wait_time = duration
	duration_timer.start()
	
	var trans_in_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	trans_in_tween.tween_property(self, "scale", Vector2.ONE, .35)
	
	yield(trans_in_tween, "finished")
	
	pulse_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_loops(-1)
	pulse_tween.tween_property(self, "scale", Vector2.ONE * 1.1, .15)

func _destroy():
	queue_free()

func _on_DurationTimer_timeout():
	pulse_tween.kill()
	
	var trans_out_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_loops(-1)
	trans_out_tween.tween_property(self, "scale", Vector2.ZERO, .35)
