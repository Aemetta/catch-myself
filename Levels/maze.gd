extends Spatial

onready var enemy = get_node("Enemy")

enum {L, R, U, D}

var path = [U, U, U, U, U, U, U, L,L,L, U,U,U, R,R,R, U,U,U, U,U,U, R,U,R,R,D, R,R,R, U]
var seek = 0
#warning-ignore:unused_class_variable
var _turn_limit = 35
#warning-ignore:unused_class_variable
var _perfect_score = 5

func next(fast):
	var v
	match path[seek]:
		R: v = enemy.goright(fast)
		U: v = enemy.goup(fast)
		L: v = enemy.goleft(fast)
		D: v = enemy.godown(fast)
		_: v = false
	
	if v: seek += 1
	if seek == path.size(): seek -= 1
	
	return v