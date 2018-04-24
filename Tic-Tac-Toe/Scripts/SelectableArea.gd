extends Area2D

onready var x = preload("res://Assets/x.png")
onready var o = preload("res://Assets/o.png")

var selected = false
export var pos = -1

func _ready():
	$mouse_over.hide()


func _on_POS_mouse_entered():
	if(!selected and !Game.win):
		$mouse_over.show()


func _on_POS_mouse_exited():
	$mouse_over.hide()

func play_x():
	if(!selected and !Game.win):
		$x_o.set_texture(x)
		$mouse_over.hide()
		selected = true
		Game.data_store[pos] = "x"
		Game.check_win(pos, "x")



func play_o(): 
	if(!selected and !Game.win):
		$x_o.set_texture(o)
		$mouse_over.hide()
		selected = true
		Game.data_store[pos] = "o"
		Game.check_win(pos, "o")

func _on_POS_input_event(viewport, event, shape_idx):
	if(event is InputEventMouseButton and event.pressed):  #event is triggered twice. Once on mouse button down and once when it goes up
		if(event.button_index == BUTTON_LEFT):
			play_x()
			Game.play_computer()
#		else:          #THIS IS FOR TESTING PURPOSES ONLY OR IF YOU WANT TO PLAY WITH 2 PLAYERS...
#			play_o()   #enable this for 2 player
 
