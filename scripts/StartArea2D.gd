extends Area2D

export(NodePath) var fade_out_rect_path
export(NodePath) var bgm_audio_path

func _on_StartArea2D_body_entered(body):
	var bgm_audio = get_node(bgm_audio_path)
	var bgm_audio_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	bgm_audio_tween.tween_property(bgm_audio, "volume_db", -80.0, .45)
	
	var fade_out_rect = get_node(fade_out_rect_path)
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(fade_out_rect, "color", Color(0, 0, 0, 1), .45)
	
	yield(tween, "finished")
	
	get_tree().change_scene("res://scenes/Game.tscn")
