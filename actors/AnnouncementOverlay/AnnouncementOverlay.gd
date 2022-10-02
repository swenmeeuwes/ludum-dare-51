extends Control

signal faded_out

onready var panel = $Panel
onready var panel_animation_player = $PanelAnimationPlayer
onready var announcement_label = $"%AnnouncementLabel"
onready var announcement_duration_timer = $AnnouncementDurationTimer
onready var announcement_audio_stream = $AnnouncementAudioStreamPlayer

func _ready():
	announcement_duration_timer.one_shot = true
	announcement_duration_timer.wait_time = .65
	
	panel_animation_player.play("idle")

func show_announcement(text, audio_stream):
	announcement_label.text = text
	panel_animation_player.play("fade_in")
	
	announcement_audio_stream.stream = audio_stream
	announcement_audio_stream.play()


func _on_PanelAnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_in":
		announcement_duration_timer.start()
	
	if anim_name == "fade_out":
		emit_signal("faded_out")


func _on_AnnouncementDurationTimer_timeout():
	panel_animation_player.play("fade_out")
