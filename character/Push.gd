extends AudioStreamPlayer3D

var samples = [preload("res://sfx/push1.wav"), preload("res://sfx/push2.wav"), preload("res://sfx/push3.wav")]

var queue_to_stop = -1

func _process(_delta):
	if queue_to_stop >= 0:
		queue_to_stop -= 1
	if queue_to_stop == 0:
		stop()

func play_random_sample():
	stream = samples[randi() % 3]
	play()

func _on_CharAni_animation_started(anim_name):
	if anim_name == "push":
		if not playing:
			play_random_sample()
		queue_to_stop = -1

func _on_CharAni_animation_finished(anim_name):
	if anim_name == "push":
		queue_to_stop = 2

func _on_Push_finished():
	play_random_sample()
