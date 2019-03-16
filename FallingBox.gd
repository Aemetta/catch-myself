extends RigidBody

onready var scrap = preload("res://Scrap.tscn").instance()

func _ready():
	contact_monitor = true
	contacts_reported = 1

func _on_FallingBox_body_entered(body):
	$"..".add_child(scrap)
	scrap.transform = self.transform
	$"..".remove_child(self)
