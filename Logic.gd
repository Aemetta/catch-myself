extends Spatial

var level_set = [preload("res://Levels/overpass.tscn"), preload("res://Levels/sokoban.tscn"), preload("res://Levels/maze.tscn"), preload("res://Levels/descent.tscn"), preload("res://Levels/sokoban2.tscn"), preload("res://Levels/help.tscn"), preload("res://Levels/end.tscn")]

onready var effects = $"../effects"
var level

var player
var player_anim
var player_mesh
var enemy
var enemy_anim
var cam

enum {L, R, U, D}

var player_his = []
var turns_left = 0
var perfect_score = 0
var level_number = 0
var post_avalanche = false
var perfects = [false, false, false, false, false, false]
var count_dir = -1

enum {PLAYING, WIN, POST_LEVEL}
var game_state = PLAYING

func _ready():
	level_number -= 1
	start_new_level()

func _process(_delta):
	cam.translation = player_mesh.to_global(Vector3(0,0,0))
	cam.translate_object_local(Vector3(0,0,10))
	
	if game_state == POST_LEVEL:
		if Input.is_action_just_pressed("ui_accept"):
			start_new_level()
	
	if Input.is_action_just_pressed("game_sprint"):
		player.speed = 5
		enemy.speed = 5
	if Input.is_action_just_released("game_sprint"):
		player.speed = 3
		enemy.speed = 3
	
	if player_anim.is_playing() or enemy_anim.is_playing() or effects.is_playing(): return
	
	if Input.is_action_just_pressed("game_undo"):
		undo()
	elif Input.is_action_just_pressed("game_restart"):
		restart(true)
		player_his = []
	
	if game_state == WIN:
		play_win_ani()
		game_state = POST_LEVEL
	if game_state == POST_LEVEL:
		return
	
	elif Input.is_action_pressed("ui_right"):advance(R, false)
	elif Input.is_action_pressed("ui_left"): advance(L, false)
	elif Input.is_action_pressed("ui_up"):   advance(U, false)
	elif Input.is_action_pressed("ui_down"): advance(D, false)

func advance(dir, fast):
	var p
	match dir:
		R: p = player.goright(fast)
		L: p = player.goleft(fast)
		U: p = player.goup(fast)
		D: p = player.godown(fast)
	#if the player successfully moved in a direction, count it as a turn
	if p:
		var e = level.next(fast)
		turns_left += count_dir
		#start counting back up when the enemy gets stuck in level 5
		if not e and turns_left > 0:
			count_dir = 1
		#when we're playing back undo, don't add turns to the undo history!
		if not fast:
			player_his.push_back(dir)

#to handle undos, the game keeps track of every turn, and when an
#undo is called it restarts the level and quickly simulates everything
#up to the previous turn.
#It also kept track of restarts so you could undo a restart, but
#that caused lag during undos after many restarts
#and nobody actually used the feature, so I ditched it
func undo():
	if player_his == []:
		return
	restart(false)
	player_his.pop_back()
	for i in player_his:
		advance(i, true)
	
	player.after_restart()
	enemy.after_restart()
	
	effects.play("undo")
	$"../Undo".play()

func restart(play_sound):
		
	game_state = PLAYING
	if level != null:
		remove_child(level)
	load_level()
	
	if play_sound:
		effects.play("undo")
		$"../Restart2".play()

func load_level():
	
	level = level_set[level_number].instance()
	add_child(level)
	
	player = get_node("Level/Player")
	player_anim = get_node("Level/Player/Slide")
	player_mesh = get_node("Level/Player/Spatial/Armature")
	enemy = get_node("Level/Enemy")
	enemy_anim = get_node("Level/Enemy/Slide")
	cam = get_node("Level/Camera")
	
	perfect_score = level._perfect_score
	turns_left = level._turn_limit
	if turns_left != 0:
		count_dir = -1
	else:
		count_dir = 1
	
	#In godot 3.1 you can no longer set negative near values in
	#the properties inspector (which makes sense for perspective
	#cameras, but is necessary for ortho in my opinion)
	cam.near = -50
	
	var playermat = preload("res://character/Player.material")
	get_node("Level/Player/Spatial/Armature/char").set_surface_material(0, playermat)
	var enemymat = preload("res://character/Enemy.material")
	get_node("Level/Enemy/Spatial/Armature/char").set_surface_material(0, enemymat)


#called from player movement script
func enemy_capture():
	if game_state == PLAYING:
		game_state = WIN

func play_win_ani():
	level.remove_child(enemy)
	effects.play("level_end")
	$"../WarpOut".play()

func start_new_level():
	if turns_left == perfect_score and level_number >= 0:
		perfects[level_number] = true
	level_number += 1
	post_avalanche = false
	effects.play("level_start")
	$"../WarpIn".play()
	if level_number == 4:
		$"../Music".switch()
	elif level_number == 6:
		$"../Music".stop()
	restart(false)
	player_his = []