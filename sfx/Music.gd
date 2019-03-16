extends AudioStreamPlayer

func switch():
	stop()
	stream = load("res://sfx/Gnossienne.ogg")
	play()