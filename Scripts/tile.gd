extends Sprite2D

@onready var riichiMgr = $"../../RiichiManager"

@onready var instanceID = self.get_instance_id()


#var tileSprite = AtlasTexture.new()
var tileTexture = Image.load_from_file("res://Sprites/TilePlaceholders.png")
var tileDict = {tilePos : 0, tileVal : 1, tileSuit : "m", isButton : false}
var tilePos : int
var tileVal : int
var tileSuit : String
var tileType : String = ""

#Boolean variables
var isButton : bool = false
var isScoringTool : bool = false
var isDisplayed : bool = false

var origin_x = 320
var origin_y = 568

var scoringScript : Node


func _ready() -> void:
	set_region_enabled(true)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_pixel_opaque(get_local_mouse_position()):
				if scoringScript.clickBuffer == false:
					if isScoringTool == true && scoringScript != null && isButton == true:
						# Add tile to array in scoringTool, then use RiichiManager sort
						scoringScript.setClickBuffer(true)
						#print("Timer start")
						scoringScript.addToHand(tileType)
						#if tilePos != null:
							# use remove_at(tilePos) to remove from the scoring hand UI
					if isScoringTool == true && isDisplayed == true && scoringScript != null:
						#print("You clicked on" + str(self))
						scoringScript.setClickBuffer(true)
						#print("Timer start")
						scoringScript.removeFromHand(instanceID,tileType)
				#Pass tile value to array for storing
				#print(tileType + " button Clicked! :)")
				#if isButton == false:
				# Handle tile discard for gameplay (later)

func setSprite(tileRegion):
	#tileSprite.set_atlas(tileTexture)
	self.texture = ImageTexture.create_from_image(tileTexture)
	self.set_region_rect(tileRegion)
	#print(str(texture.region))

func initializeSprite(tileCode:String):
	tileVal = int(tileCode[0])
	tileSuit = tileCode[-1]
	var suitVal = get_suit(tileSuit)
	#var region = calcTileRegion()

func setPos(pos:Vector2):
	self.position.x = pos.x
	self.position.y = pos.y

func setHandPosition(handPos):
	global_position.x = origin_x + ((handPos - 1) * 40)
	global_position.y = origin_y


func initializeButton(type,newposition,buttonBool,scoringBool,displayBool):
	isButton = buttonBool
	isScoringTool = scoringBool
	isDisplayed = displayBool
	
	tileType = type
	scoringScript = get_node("../..")
	self.name = "TileButton_" + str(type)
	tileVal = int(type[0])
	tileSuit = type[-1]
	var suitVal = get_suit(tileSuit)#riichiMgr.sortingKey.get(tileSuit)
	var region = calcTileRegion(tileVal,suitVal)
	#Calls calcTileRegion, using the tileVal, and get_suit as arguments to calculate the region 
	setSprite(region)
	global_position = newposition


#Calculates the region of the sprite sheet to use when generating the tile sprite2D (or TextureButton) object
func calcTileRegion(val,suitVal):
	var region : Rect2
	if (suitVal > 2):
		var y = 96
		match suitVal:
			3 : region = Rect2(0,y,32,32)		# East
			4 : region = Rect2(96,y,32,32)		# South (North and South are swapped accidentally on sprite sheet. Fix later)
			5 : region = Rect2(64,y,32,32)		# West
			6 : region = Rect2(32,y,32,32)		# North
			7 : region = Rect2(128,y,32,32)		# Haku (Red)	(Also re-arrange dragons on sprite sheet later, to be w,g,r)
			8 : region = Rect2(160,y,32,32)		# Hatsu (Green)
			9 : region = Rect2(192,y,32,32)	# Chun (White)
	else:
		var x = (val - 1) * 32
		var y = suitVal * 32
		region = Rect2(x,y,32,32)
	
	#print(str(x) + " " + str(y) + " " + str(w) + " " + str(h))
	return region


#Change this out to use the "SortingKey" dict within RiichiManager, adjusting the calc tile region accordingly
func get_suit(suit):
	var suitVal = 0
	match suit:
		"m" : suitVal = 0
		"p" : suitVal = 1
		"s" : suitVal = 2
		"e" : suitVal = 3
		"o" : suitVal = 4
		"w" : suitVal = 5
		"n" : suitVal = 6
		"x" : suitVal = 7
		"y" : suitVal = 8
		"z" : suitVal = 9
	return suitVal
