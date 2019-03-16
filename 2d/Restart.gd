extends TextureRect

func _process(_delta):
	if $"../Logic".turns_left <= 0 and $"../Logic".count_dir == -1 and not $"../Pause".visible and not $"../Win".visible:
		visible = true;
	else:
		visible = false;