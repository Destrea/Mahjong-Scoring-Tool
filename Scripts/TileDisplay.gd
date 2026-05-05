extends Node

@onready var GManager = $".."

var testSeq1 = ['1m','1m','1m','2m','2m','2m','3p','3p','3p','4p','4p','4p','5s','5s'] # 4 triplets and a pair - 111 222 333 444 55
var testSeq2 = ['1s']
var tileScene = load("res://Scenes/Tile.tscn")

# Called when the node enters the scene tree for the first time.


func displayTiles(givenHand):
	var i = 1
	var val = 0
	var suit
	for pos in givenHand:
		var Tile = tileScene.instantiate()
		add_child(Tile)
		val = int(_get_First(pos))
		suit = _get_Last(pos)
		var region = calcTileRegion(val,suit)
		Tile.setSprite(region)
		Tile.setHandPosition(i)
		i += 1

func calcTileRegion(val,suit):
	var suitVal = get_suit(suit)
	var x = (val - 1) * 32
	var y = (suitVal - 1) * 32
	var w = val * 32
	var h = suitVal * 32
	var region = Rect2(x,y,32,32)
	
	#print(str(x) + " " + str(y) + " " + str(w) + " " + str(h))
	return region


func get_suit(suit):
	var suitVal = 0
	match suit:
		"m" : suitVal = 1
		"p" : suitVal = 2
		"s" : suitVal = 3
	
	return suitVal

func _get_Last(string):
	return string[-1]

# Returns the first letter of the string passed
func _get_First(string):
	return string[0]


func _on_test_handbutton_pressed() -> void:
	displayTiles(testSeq1)
