extends AudioStreamPlayer

func _on_effects_animation_finished(anim_name):
	if anim_name == "level_start":
		Audio.bus
