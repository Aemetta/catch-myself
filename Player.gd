extends Spatial

onready var mesh = get_node("Spatial")
onready var char_ani = get_node("CharAni")
onready var slide_ani = get_node("Slide")
onready var push_box = get_node("Spatial/Armature/char/PushBox")
onready var push_box2 = get_node("Spatial/Armature/char/PushBox/PushBox2")

onready var logic = get_node("../..")
onready var map   = get_node("../GridMap")
onready var id_air    = map.INVALID_CELL_ITEM
onready var id_me     = map.mesh_library.find_item_by_name("PlayerDummy")
onready var id_enemy  = map.mesh_library.find_item_by_name("EnemyDummy")
onready var id_invis  = map.mesh_library.find_item_by_name("InvisWall")
onready var id_box    = map.mesh_library.find_item_by_name("Box")
onready var id_ladder = map.mesh_library.find_item_by_name("Ladder")

var is_enemy = false
var speed = 3.0
export (float) var start_angle = 0

var move_save = Vector3(0,0,0)
var box_to_place = [];

func _ready():
	char_ani.play("default")
	push_box.visible = false
	mesh.rotate_y(start_angle)
	if self.name == "Enemy":
		var c = id_me
		id_me = id_enemy
		id_enemy = c
		is_enemy = true

func after_restart():
	mesh.rotate_y(PI/2)


func goright(fast): return move(Vector3( 1, 0, 0), 0.0, fast)
func goleft(fast):  return move(Vector3(-1, 0, 0), PI, fast)
func goup(fast):    return move(Vector3(0, 0, -1), PI * 0.5, fast)
func godown(fast):  return move(Vector3(0, 0,  1), PI * 1.5, fast)


func move(move, angle, fast):
	
	var current_position = self.transform
	var cx = current_position.origin.x - 1
	var cy = current_position.origin.y
	var cz = current_position.origin.z - 1
	
	#There's a PlayerDummy tile in the spot we're standing,
	#so delete it when we take a step
	map.set_cell_item(cx, cy, cz, id_air)
	
	#As we move, check which blocks are ahead, above and below us
	
	#directly forward
	var cell1  = map.get_cell_item(cx + move.x*1, cy, cz + move.z*1)
	#forward and down
	var cell1d = map.get_cell_item(cx + move.x*1, cy - 1, cz + move.z*1)
	#backward and down
	var cellnd = map.get_cell_item(cx - move.x*1, cy - 1, cz - move.z*1)
	#forward and up
	var cell1u = map.get_cell_item(cx + move.x*1, cy + 1, cz + move.z*1)
	#two ahead (to see if there's room to push a box)
	var cell2  = map.get_cell_item(cx + move.x*2, cy, cz + move.z*2)
	#directly down (what we're currently standing on)
	var cell0d = map.get_cell_item(cx, cy - 1, cz)
	#directly up (to see if there's clearance to climb upwards)
	var cell0u = map.get_cell_item(cx, cy + 1, cz)
	
	
	if cell1 == id_enemy and cell0d != id_air and cell1d != id_air:
		#If we walk into the enemy (or the enemy walks into us)
		#and there's ground beneath both our feet, end the level
		logic.enemy_capture()
	
	elif cell1u == id_invis:
		#I placed invisible tiles floating a bit in the air so that
		#as the enemy walks past it doesn't get overwritten by EnemyDummy.
		#Unfortunately these tiles are invisible so you can't see them in
		#the editor! I could've made a material that goes invisible when
		#the game starts or something, but I decided not to worry about it
		if not is_enemy:
			move = Vector3(0,0,0)
	
	elif cell1 == id_ladder and cell0u == id_air:
		#climb up ladder
		move.y = 1
		if cell1u == id_ladder:
			move.x = 0
			move.z = 0
		elif cell1u == id_enemy:
			logic.enemy_capture()
		elif cell1u != id_air:
			move = Vector3(0,0,0)
	
	elif cell1 == id_ladder and cell0u == id_enemy:
		logic.enemy_capture()
		move = Vector3(0,1,0)
	
	elif cell0d == id_air and cellnd != id_air:
		#climb down ladder
		move = Vector3(0, -1, 0)
		angle += PI
	
	elif cell1 == id_air and cell1d != id_air and cell1d != id_enemy and cell0d != id_air:
		#walk forward
		pass
	
	elif cell1 == id_box and cell2 == id_air and cell0d != id_air:
		#push box
		map.set_cell_item(cx + move.x*1, cy, cz + move.z*1, id_air)
		push_box.visible = true
		#store the tile position to put the box after
		#the pushing animation plays
		box_to_place = [[cx + move.x*2, cy, cz + move.z*2, 0]]
		if cell1u == id_box:
			#also push the box on top of the one we're pushing
			map.set_cell_item(cx + move.x*1, cy+1, cz + move.z*1, id_air)
			push_box2.visible = true
			box_to_place.append([cx + move.x*2, cy+1, cz + move.z*2, 1])
		for i in box_to_place:
			if box_is_in_air(i):
				#place an invisible tile where the box will go
				#so that it's functionally there
				#while the animation plays
				map.set_cell_item(i[0], i[1], i[2], id_invis)
	
	elif cell1 == id_air and cell0d == id_ladder:
		#turn around to go down ladder
		if cell1d == id_enemy:
			logic.enemy_capture()
		angle += PI
		move.y = -1
	
	else:
		#can't move
		move = Vector3(0,0,0)
	
	
	if move != Vector3(0,0,0):
		mesh.rotation = Vector3(0,0,0)
		mesh.rotate_y(angle)
		push_box.rotation = Vector3(0, -mesh.rotation.y - PI / 2, 0)
	
	#place a PlayerDummy or EnemyDummy tile wherever we move
	#for two reasons: A) to detect if the player and enemy
	#touch, B) so the enemy can stand in the way of the player
	#pushing a box (and vice versa)
	map.set_cell_item(cx + move.x, cy + move.y, cz + move.z, id_me)
	
	
	#In most circumstances, after moving the player goes into
	#an animation state
	if(!fast):
		
		#hold onto the position we're moving to, as we have to
		#translate the player once the animation is done
		move_save = move
		
		#slide_ani smoothly moves the player between one
		#cell and the next, while char_ani holds the actual
		#armature animations
		if move.x != 0 or move.z != 0:
			if move.y == 0:
				slide_ani.play("fwd", -1, speed)
			elif move.y == 1:
				slide_ani.play("over", -1, speed)
			else:
				slide_ani.play("backdown", -1, speed)
		elif move.y == -1:
			slide_ani.play("down", -1, speed)
		elif move.y == 1:
			slide_ani.play("up", -1, speed)
		
		if move != Vector3(0,0,0):
			$"StepSound".play("StepSounds", -1, speed)
			if push_box.visible:
				char_ani.play("push", -1, speed)
			elif move.x == 0 and move.z == 0:
				char_ani.play("climb", -1, speed)
			else:
				char_ani.play("run", -1, speed)
			#returns a value of true to the Logic node
			#telling it we managed to take a step
			return true
		#if the player fails to move, the enemy won't move either
		#if the enemy fails to move, if it's level 5 or 6 they'll
		#look around
		else: return false
	
	#when we undo, we simulate the player's movements
	#without playing any animation
	else:
		self.translate(move)
		for i in box_to_place:
			if box_is_in_air(i):
				map.set_cell_item(i[0], i[1], i[2], id_box)
		box_to_place = []
		push_box.visible = false
		
		if move != Vector3(0,0,0): return true
		else: return false



func _on_Slide_animation_finished(anim_name):
	
	if anim_name == "fwd" or anim_name == "over":
		#return to idle animation
		char_ani.play("default")
	else:
		char_ani.play("climb", -1, 0.0)
		mesh.rotate_y(PI * .5)
	
	slide_ani.seek(0, true)
	self.translate(move_save)
	
	push_box.visible = false
	for i in box_to_place:
		if box_is_in_air(i):
			map.set_cell_item(i[0], i[1], i[2], id_box)
		else:
			var fb = preload("res://FallingBox.tscn").instance()
			get_parent().add_child(fb)
			#bring box entity to player's position
			fb.translate(self.translation)
			#translate one unit in the direction we were moving
			fb.translate(move_save)
			#translate one unit up if it's a stacked box
			fb.translate(Vector3(0,i[3],0))
			
			#add some fun rotating motion c:
			fb.linear_velocity += move_save*1.5
			fb.angular_velocity += Vector3(move_save.z*3, 0, -move_save.x*3)
	
	box_to_place = []

#misnamed function: this returns true if the position
#we want to place a box is on the ground
func box_is_in_air(i):
	var spot = map.get_cell_item(i[0], i[1]-1, i[2])
	return spot != id_air and spot != id_enemy

#alternate idle animation for the enemy in levels 5 and 6
#called from the level script
func look_around():
	char_ani.play("evil")