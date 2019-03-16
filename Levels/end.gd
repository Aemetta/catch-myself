extends Spatial

onready var enemy = get_node("Enemy")

enum {L, R, U, D}

#warning-ignore:unused_class_variable
var _turn_limit = 0
#warning-ignore:unused_class_variable
var _perfect_score = 0

func next(fast):
	return true