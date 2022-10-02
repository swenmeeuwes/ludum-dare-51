extends Control

onready var score_label = $ScoreLabel

func show_score(score: int):
	score_label.text = String(score)
