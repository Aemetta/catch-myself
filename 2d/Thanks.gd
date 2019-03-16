extends TextureRect

onready var logic = $"../Logic"
onready var award = preload("res://2d/icon_award.png")

func _process(_delta):
	if logic.level_number == 6 and $"../Pause".visible == false:
		visible = true;
		$"../Score".visible = false
		if logic.turns_left == logic.perfect_score:
			self.visible = true
			if logic.perfects[0]:
				$"./awards/award_0".texture = award
			if logic.perfects[1]:
				$"./awards/award_1".texture = award
			if logic.perfects[2]:
				$"./awards/award_2".texture = award
			if logic.perfects[3]:
				$"./awards/award_3".texture = award
			if logic.perfects[4]:
				$"./awards/award_4".texture = award
			if logic.perfects[5]:
				$"./awards/award_5".texture = award
	else:
		visible = false