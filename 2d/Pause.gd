extends NinePatchRect

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = !visible

func _on_Text2_pressed():
	visible = false

func _on_Text3_pressed():
	get_tree().quit()

func _on_slider_value_changed(value, bus_name, play_sample):
	if play_sample:
		$"../Undo".play()
	var bus = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus, value)
	if value == -50:
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)
