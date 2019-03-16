extends Spatial

onready var enemy = get_node("Enemy")

enum {L, R, U, D}

var path = [U, U, U, R, U, U, L, D, L, D, R, R, R, U,U,U,U,U,U, L,L, U, L,L, D, L,L, D,D, L, U, L, U, L, U,U,U,U, L,R, L,R, L,R, L,R, L,R, L,R, D,D,D,D, R, D,D,D,D, L, D, D, L, L,L,L,L, D,D,D,D, L,L,L,L, D,L]
var seek = 0
#warning-ignore:unused_class_variable
var _turn_limit = 65
#warning-ignore:unused_class_variable
var _perfect_score = 68

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
	
	if not v:
		enemy.look_around()
	
	return v