extends Node

onready var game_won = preload("res://Scenes/GameWon.tscn")
#positions of rows, columns and diagonals to check is stored in this dictionary
onready var checker_dict = {
	"row_one": [0,1,2],
	"row_two": [3,4,5],  
	"row_three" : [6,7,8],
	"col_one" : [0,3,6],
	"col_two" : [1,4,7],
	"col_three" : [2,5,8],
	"dia_one" : [0,4,8],
	"dia_two" : [2,4,6]    
}

var possible_win_x = []
var possible_win_o = []

var data_store = [] #stores the current values in each pos
var win = false #to check won or not

#function to get the main node
func get_main_node():
	var root = get_tree().get_root()
	return root.get_child(root.get_child_count() - 1)

func _ready():
	reset_data_store()
	pass

func reset_data_store():
	#this function resets empty values in data store
	win = false
	data_store = []
	for i in range(0,9):
		data_store.append("--")
	


func get_keys_for_value(value): #this function returns the keys containing that particular value
	var all_keys = checker_dict.keys()
	var keys = []
	for i in range(0, all_keys.size()):
		var values = checker_dict[String(all_keys[i])]
		for j in range(0, values.size()):
			if(values[j] == value):
				keys.append(String(all_keys[i]))
	return keys


func check_win(pos, letter): #checks if won or not after every input
	var tally = 0
	var key = []
	var keys_to_check = get_keys_for_value(pos)
	
	#check if win occured on all this keys
	for i in range(0,keys_to_check.size()):
		key = keys_to_check[i]
		for j in range(0, checker_dict[key].size()):
			if(data_store[checker_dict[key][j]] == letter):
				tally +=1
		
		if(tally == 3):
			win = true
			break
		elif(tally == 2):
			if(letter == "x"):
				possible_win_x.append(key)
			else:
				possible_win_o.append(key)
			tally = 0
		else:
			tally = 0
	
	
	if(win):
		won_game(checker_dict[key])

func won_game(win_key): #to make a win more interesting.
	var inst = game_won.instance()
	var node = "POS" + String(win_key[1]) #the middle pos of the whole key
	inst.position = get_main_node().get_node("grid/" + node).global_position
	var diff = win_key[2] - win_key[0]
	
	match diff: #equivalent to switch statement
		4:#comes when win key is diagonal
			inst. rotation = deg2rad(-45)
		8:# this too
			inst. rotation = deg2rad(45)
		6:# this is for vertical
			inst. rotation = deg2rad(90)
	
	get_main_node().add_child(inst)


func play_winning_move():
	var played_winning_move = false
	var played_pos = -1
	var key_to_remove = -1    #sometimes once possible wins are stored, that position might be taken by other player and no longer useful

	#all possible win outcomes are stored in possible_win_o array.
	if(possible_win_o.size() > 0): 
		#this means there is a winning possibility
		for i in range(0, possible_win_o.size()):
			#go through all those possibilities
			for j in range(0, checker_dict[possible_win_o[i]].size()):
				#go through all the positions in those possiblities
				if(data_store[checker_dict[possible_win_o[i]][j]] == "--"):
					#if a position is empty
					played_pos = checker_dict[possible_win_o[i]][j] #that should be the position to play
					key_to_remove = i
					#now lets find that node for that particular pos to play
					var node = "POS" + String(played_pos)
					get_main_node().get_node("grid/" + node).play_o()
					played_winning_move = true
					
				if(played_winning_move):
					return played_winning_move
					
		if(key_to_remove != -1):
			possible_win_o.remove(key_to_remove)
		else:
			possible_win_o = []
	
	return played_winning_move  #in case it's false


func block_players_win():
	#same as play_winning_move() but it concers the winning possibilities of x, i.e., possible_win_x array
	var blocked_player = false
	var played_pos = -1
	var key_to_remove = -1    #sometimes once possible wins are stored, that position might be taken by other player and no longer useful

	#all possible win outcomes are stored in possible_win_x array.
	if(possible_win_x.size() > 0): 
		#this means there is a winning possibility
		for i in range(0, possible_win_x.size()):
			#go through all those possibilities
			for j in range(0, checker_dict[possible_win_x[i]].size()):
				#go through all the positions in those possiblities
				if(data_store[checker_dict[possible_win_x[i]][j]] == "--"):
					#if a position is empty
					played_pos = checker_dict[possible_win_x[i]][j] #that should be the position to play
					key_to_remove = i
					#now lets find that node for that particular pos to play
					var node = "POS" + String(played_pos)
					get_main_node().get_node("grid/" + node).play_o()
					blocked_player = true
					
				if(blocked_player):
					return blocked_player
					
		if(key_to_remove != -1):
			possible_win_x.remove(key_to_remove)
		else:
			possible_win_x = []
	
	return blocked_player  #in case it's false

func check_for_draw():
	var draw = true
	for i in range(0, data_store.size()):
		if(data_store[i] == "--"):
			draw = false  #if one of them is empty, it's not draw
	return draw

func play_computer():
	
	var won_by_comp = play_winning_move()     #----->FIRST PRIORITY
	if(won_by_comp):
		return                 #game ends
	
	var blocked_players_win = block_players_win()     #------>SECOND PRIORITY
	if(blocked_players_win):
		return                 #no other move needed
#
#
	var draw = check_for_draw()        #------->THIRD PRIORITY
	if(draw):
		return                  #it's like stalemate. Nothing to do
	
	#if nothing, take a random pos and play
	var can_take_pos = false #boolean to check if that particular position can be taken
	while(!can_take_pos):
		#as long as that position canot be taken we need another random pos
		var pos = randi()%8  #random numbers from 0 - 8
		if(data_store[pos] == "--"):
			can_take_pos = true
			var node = "POS" + String(pos)
			get_main_node().get_node("grid/"+node).play_o()



func _process(delta):
	if(Input.is_key_pressed(KEY_ENTER)): #to restart game
		possible_win_o = []
		possible_win_x = []
		reset_data_store()
		get_tree().reload_current_scene()
	
	if(Input.is_action_just_pressed("ui_select")):  #for testing, press space
		play_computer()



















