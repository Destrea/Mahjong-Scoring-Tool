@tool
extends EditorScript


# Called when the node enters the scene tree for the first time.
func _run():
	var suits = {"man": "m" , 
		 "pin" : "p", 
		 "sou": "s"}
	
	var testSuit = 'm'
	var curSuit = suits.get('man')
	if curSuit == testSuit:
		print("Same")
	
