extends AudioStreamPlayer


func _ready():
	var target_volume = volume_db
	
	volume_db = -80	
	var audio_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	audio_tween.tween_property(self, "volume_db", target_volume, 1)
