extends AudioStreamPlayer3D

var samples = [preload("res://sfx/step1.wav"), preload("res://sfx/step2.wav"), preload("res://sfx/step3.wav"), preload("res://sfx/step4.wav"), preload("res://sfx/step5.wav"), preload("res://sfx/step6.wav")]

func play_random_sample():
	stream = samples[randi() % 6]
	play()