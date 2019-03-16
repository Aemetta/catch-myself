extends Label

func _process(_delta):
	var s = $"../../Logic".turns_left
	text = String(s)
	modulate = Color(1, 1, 1)
	if $"../../Logic".count_dir == -1:
		if s <= 0:
			modulate = Color(1, 0, 0)
		elif s <= 10:
			modulate = Color(1, 1, 0)