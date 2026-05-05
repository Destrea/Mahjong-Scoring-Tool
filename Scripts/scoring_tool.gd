extends Node

#This is used to test possible scoring for valid riichi Mahjong hands.
#Including open/closed hands, riichi, tsumo, round and seat winds, and dora tiles.

@onready var yaku_Manager = $YakuManager
@onready var scoring_Manager = $ScoringManager
@onready var riichi_Manager = $RiichiManager

@onready var tileButton = load("res://Scenes/Tile.tscn")
@onready var picker = $"Picker"
@onready var display = $DisplayUI
var allTiles = ['1m','2m','3m','4m','5m','6m','7m','8m','9m',
				'1p','2p','3p','4p','5p','6p','7p','8p','9p',
				'1s','2s','3s','4s','5s','6s','7s','8s','9s',
				'0e','0o','0w','0n','0x','0y','0z']

var debug = true
@onready var debugLabel = $"DisplayUI/Debug Label"
@export var chosenHand = []
@export var handDisplay = []
# Remember to code in hard limits to the maximum size of the array at 14 tiles!!!!

var clickBuffer = false


# Scoring variable defaults
var tsumo : bool = false
var riichi : bool = false
var doubleriichi : bool = false
var chankan : bool = false
var ippatsu : bool = false
var rinshan : bool = false
var handIsOpen : bool = false
var haiteihoutei : bool = false
var honbaBox : int = 0
var doraBox : int = 0

var scale : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilePicker()



func setClickBuffer(value:bool):
	clickBuffer = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clickBuffer == true:
		await get_tree().create_timer(0.1).timeout
		setClickBuffer(false)
	debugUI()
	pass

func debugUI():
	if debug == true:
		debugLabel.text = "Chosen Hand: " + str(chosenHand) + "\nHandDisplay: " + str(handDisplay)

func displayHand():
	#print("Before: " + str(handDisplay))
	handDisplay = sortByID(handDisplay)
	#print("After: " + str(handDisplay))
	var newPosition : Vector2
	var i = 0
	for tile in handDisplay:
		newPosition = handPosition(i)
		#print("NewPosition: " + str(newPosition))
		i+=1
		tile.position.x = newPosition.x
		#tile.position.y = newPosition.y
	#print("------------------------------------------------")


func sortByID(listToSort):
	var copied = listToSort
	var sortedIDs = []
	for handPos in chosenHand:
		var i = 0
		for ID in copied:
			if str(ID).contains(handPos):
				sortedIDs.append(ID)
				copied.remove_at(i)
				#print("Sorted: " + str(sortedIDs))
				#print("Copied: " + str(copied))
			i+=1
	return sortedIDs

func handPosition(i):
	var startPos = get_node("DisplayUI").position
	var curPos = Vector2(startPos.x,startPos.y)
	curPos.x = (i * (32 * (0.75 * scale)))
	return curPos


# Dynamically generates a 
func tilePicker():
	
	var row = 0
	var col = 0
	
	for item in allTiles:
		var button = tileButton.instantiate()
		picker.add_child(button)
		scale = button.get_scale().x
		var position = calcPos(row,col,scale)
		col+=1
		if col == 9:
			col = 0
			row+=1
		button.initializeButton(item,position,true,true,false)
		#iterate through allTiles, passing the "item" string to the initialize() function, after generating a tile.
		# The initialize function will set up the oobject's name and sprite, and allows the button to store
		# information that will be used later when adding them to the "chosenHand"
	
	var pickerBackground = get_node("Picker/Picker Background")
	pickerBackground.size.x = (32*scale) * 10
	pickerBackground.size.y = (32*scale) * 5

func calcPos(row, col,givenScale):
	var pickerPos = get_node("Picker").position
	var position = Vector2(pickerPos.x + (32*givenScale),pickerPos.y + (32*givenScale))
	position.x += col * (32*givenScale)
	position.y += row * (32*givenScale)
	return position



func addToHand(tile):
	#add tile to chosenHand
	var curSize = chosenHand.size()
	if chosenHand.size() <= 13:
		chosenHand.append(tile)
		riichi_Manager.sortOneHand(chosenHand,curSize+1)
		#print(chosenHand)
		var tileNode = tileButton.instantiate()
		display.add_child(tileNode)
		handDisplay.append(tileNode)
		#print(handDisplay)
		var lastSpot = chosenHand.size()
		var curPos = handPosition(lastSpot-1)
		#print("addtohand pos: " + str(curPos))
		tileNode.initializeButton(tile,curPos,false,true,true)
		displayHand()
		#Add the tile to UI, instantiated as an object that uses a boolean to distinguish it, allowing you to click it in
		# The hand UI to remove it. Additionally, store the position of the newly added piece to the array
	else:
		print("hand Size already at 14")
		print(chosenHand)

func removeFromHand(tileID,tile):
	var index = chosenHand.find(tile)
	
	if index != -1:
		chosenHand.remove_at(index)
		var delTile = instance_from_id(tileID)
		var handIndex = handDisplay.find(delTile)
		#print(delTile)
		handDisplay.remove_at(handIndex)
		#print("Deleting "+ str(delTile) + " at index "+ str(handIndex))
		delTile.free()
		#print(handDisplay)
		#print(chosenHand)
		displayHand()
	else:
		print("Error with index in removeFromHand")



#Options interface functions
func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_clear_pressed() -> void:
	scoring_Manager.clearAll()

# Hand Open/Closed Toggle
func _on_tsumo_toggled(toggled_on: bool) -> void:
	tsumo = toggled_on

func _on_riichi_box_toggled(toggled_on: bool) -> void:
	riichi = toggled_on

func _on_double_riichi_toggled(toggled_on: bool) -> void:
	doubleriichi = toggled_on

func _on_chankan_toggled(toggled_on: bool) -> void:
	chankan = toggled_on

func _on_ippatsu_toggled(toggled_on: bool) -> void:
	ippatsu = toggled_on

func _on_rinshan_kaihou_toggled(toggled_on: bool) -> void:
	rinshan = toggled_on

func _on_is_open_toggled(toggled_on: bool) -> void:
	handIsOpen = toggled_on
	yaku_Manager.handClosed = !toggled_on

func _on_haitei_houtei_toggled(toggled_on: bool) -> void:
	haiteihoutei = toggled_on

func _on_honba_box_item_selected(index: int) -> void:
	honbaBox = index

func _on_dora_box_item_selected(index: int) -> void:
	doraBox = index


func _on_round_wind_option_item_selected(index: int) -> void:
	match index:
		0 : yaku_Manager.roundWind = "East" 
		1 : yaku_Manager.roundWind = "South"
		2 : yaku_Manager.roundWind = "West"
		3 : yaku_Manager.roundWind = "North"


func _on_seat_wind_option_item_selected(index: int) -> void:
	match index:
		0 : yaku_Manager.seatWind = "East" 
		1 : yaku_Manager.seatWind = "South"
		2 : yaku_Manager.seatWind = "West"
		3 : yaku_Manager.seatWind = "North"
