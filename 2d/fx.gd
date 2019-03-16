extends Node2D

var rect = Rect2(0,0,10000,10000)

func _draw():
	draw_rect(rect, modulate, true)