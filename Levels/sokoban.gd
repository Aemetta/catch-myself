extends Spatial

onready var enemy = get_node("Enemy")

enum {L, R, U, D}

var path = [U, U, R, R, R]
var seek = 0

#warning-ignore:unused_class_variable
var _turn_limit = 65
#warning-ignore:unused_class_variable
var _perfect_score = 7

func _ready():
	for _i in range(0,12):
		path.append(U)
	for _i in range(0,12):
		path.append(R)
	path.append(D)
	path.append(D)
	for _i in range(0,16):
		path.append(R)
	path.append(U)
	path.append(R)
	
	if not $"..".post_avalanche:
		$"RigidBody/GridMapFall".visible = true

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
	
	if seek == 14 and not $"..".post_avalanche:
		$"..".post_avalanche = true
		$"RigidBody".gravity_scale = 1
		$"Crack".play()
	
	return v