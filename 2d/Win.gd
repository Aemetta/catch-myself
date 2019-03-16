extends TextureRect

onready var logic = $"../Logic"
onready var award = preload("res://2d/icon_award.png")

func _process(_delta):
	if logic.game_state == logic.POST_LEVEL and $"../Pause".visible == false:
		self.visible = true
	else:
		self.visible = false
	
	if logic.turns_left == logic.perfect_score:
		$"won".visible = false
		$"perfect".visible = true
		$"award_icon".visible = true
	else:
		$"won".visible = true
		$"perfect".visible = false
		$"award_icon".visible = false