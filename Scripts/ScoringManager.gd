#@tool
#extends EditorScript
extends Node

@onready var yakuMgr = $"../YakuManager"
@onready var scoringScript = $".."

@onready var yakuLabel = $"../YakuText"
@onready var hanLabel = $"../HanText"
@onready var tierLabel = $"../HandTier"
@onready var scoreLabel = $"../Score"

var handToCalc = []
var handCopy = []

var isYakuman = false
var doubleYakuman = false
var isDealer = false

var dealerTable = []
var nondealerTable = []

var handYaku = []
var handHan = []
var hanTotal : int = 0
var handScore : int = 0
var numFu : int = 0
var closedYakuTable = {"Tsumo" : 1, "Riichi" : 1, "Ippatsu": 1, "Pinfu" : 1, "Iipeikou" : 1, "Double Riichi" : 2, "Haitei Raoyue" : 1, "Houtei Raoyui" : 1, "Rinshan Kaihou" : 1, "Chankan" : 1, "Tanyao" : 1,
						"Chantaiyao" : 2, "Sanshoku Doujun" : 2, "Ittsu" : 2, "Toitoi" : 2, "Sanankou" : 2, "Sanshoku Doukou" : 2, "Sankantsu" : 2, "Chiitoitsu":2, "Honroutou" : 2, "Shousangen" : 2, "Honitsu": 3, "Junchan Taiyao" : 3,
						"Ryanpeikou" : 3,"Chinitsu" : 6}

var openYakuTable = {"Haitei Raoyue" : 1, "Houtei Raoyui" : 1, "Rinshan Kaihou" : 1, "Chankan" : 1, "Tanyao" : 1, "Chantaiyao" : 1, "Sanshoku Doujun" : 1, "Ittsu" : 1, "Toitoi" : 2, "Sanankou" : 2, "Sanshoku Doukou" : 2, "Sankantsu" : 2, "Honroutou" : 2, "Shousangen" : 2, "Honitsu": 2, "Junchan Taiyao" : 2,
						"Chinitsu" : 5}

# Han needed : Hand Types 
var handTier = ""



# Clears all stored values, scoring, tiles, etc.
func clearAll():
	handHan.clear()
	handYaku.clear()
	handToCalc.clear()
	handCopy.clear()
	yakuMgr.resetValues()
	for item in scoringScript.handDisplay:
		var itemID = instance_from_id(item.get_instance_id())
		itemID.queue_free()
	
	scoringScript.handDisplay.clear()
	scoringScript.chosenHand.clear()
	
	scoringScript.displayHand()
	isYakuman = false
	handTier = "N/A"
	handScore = 0
	yakuLabel.text = ""
	hanLabel.text = "" 
	tierLabel.text = handTier
	scoreLabel.text = str(handScore)




func _process(delta: float) -> void:
	handToCalc = scoringScript.chosenHand

func optionsBoxes():
	if scoringScript.handIsOpen == false:
		if scoringScript.tsumo == true:
			handYaku.append("Tsumo")
		if scoringScript.riichi == true && scoringScript.doubleriichi == false:
			handYaku.append("Riichi")
		if scoringScript.doubleriichi == true:
			handYaku.append("Double Riichi")
		if scoringScript.ippatsu == true:
			handYaku.append("Ippatsu")
		
	if scoringScript.chankan == true:
		handYaku.append("Chankan")
	if scoringScript.rinshan == true:
		handYaku.append("Rinshan Kaihou")
	if scoringScript.haiteihoutei == true:
		handYaku.append("Haitei Raoyue")
		
	print(handYaku)


#Finds the Han and Fu of a given hand
func getHan(handYaku):
	handHan.clear()
	hanTotal = 0
	if isYakuman == false:
		for item in handYaku:
			#print(scoringScript.handIsOpen)
			if scoringScript.handIsOpen == true && openYakuTable.has(item):
				handHan.append(openYakuTable[item])
				print("HandHan: " + str(handHan))
			if scoringScript.handIsOpen == false:
				handHan.append(closedYakuTable[item])
		if yakuMgr.yakuhaiCount > 0:
			handYaku.append("Yakuhai")
			handHan.append(yakuMgr.yakuhaiCount)
		if(scoringScript.doraBox > 0):
			handYaku.append("Dora Tiles")
			handHan.append(scoringScript.doraBox)
		for item in handHan:
			hanTotal += item
		

# Calculates the value of the hand based on its Han and Fu
func calcTier(hanTotal : int):
	if doubleYakuman == true:
		handTier = "Double Yakuman"
		handScore = 16000
	elif isYakuman == true && doubleYakuman == false:
		handTier = "Yakuman"
		handScore = 16000
	elif hanTotal < 5:
		handTier = ""
	elif hanTotal in range(5,6):
		handTier = "Mangan"
		handScore = 4000
	elif hanTotal in range(6,8):
		handTier = "Haneman"
		handScore = 6000
	elif hanTotal in range(8,11):
		handTier = "Baiman"
		handScore = 8000
	elif hanTotal in range(11,13):
		handTier = "Sanbaiman"
		handScore = 12000
	elif hanTotal >= 13:
		handTier = "Counted Yakuman"
		handScore = 16000
	
	if doubleYakuman == true:
		handScore *= 2 
	
	if isDealer:
		handScore *= 3
	else:
		handScore *= 2
		

func checkYakuman(foundYaku):
	if foundYaku.has("Kokushi Musou") || foundYaku.has("Suuankou")||foundYaku.has("Daisangen")||foundYaku.has("Shousuushii")||foundYaku.has("Daisuushii")||foundYaku.has("Tsuuiisou")||foundYaku.has("Chinroutou")||foundYaku.has("Ryuuiisou")||foundYaku.has("Chuuren Poutou"):
		isYakuman = true
		
	if foundYaku.has("Suuankou") && foundYaku.has("Daisangen"):
		doubleYakuman = true
		

func handFu():
	var melds = yakuMgr.meldContains
	var triplets = yakuMgr.tripletTracker
	var fu = 20
	
	#Triplets
	for key in triplets:
		if(yakuMgr.handClosed == true):
			if (yakuMgr._get_Val(key) == "1" || yakuMgr._get_Val(key) == "9"):
				fu += 8
			else:
				fu += 4
		else:
			if (yakuMgr._get_Val(key) == "1" || yakuMgr._get_Val(key) == "9"):
				fu += 4
			else:
				fu += 2
	#Add waits
	#Add Yakuhai pair
	if (yakuMgr.pair != "") && (yakuMgr._get_Val(yakuMgr.pair) == "0"):
		fu += 2
	
	var returnVal = snapped(fu, 10)
	return returnVal

func getAllYaku():
	if handToCalc.size() == 14:
		handCopy = handToCalc.duplicate()
		yakuMgr.find_Yaku(handCopy)
		print("-----------------------------------------------------------------------------------------------")
		print("Calculate Testing")
		handYaku = yakuMgr.yakuList		#Copies the yakuList over from YakuManager, found by searching the hand's contents
		checkYakuman(handYaku)			#Checks if the hand already contains a yakuman
		print(isYakuman)
		if isYakuman == false:
			optionsBoxes()					#Adds the associated checkbox Yaku, if it isnt a Yakuman
			getHan(handYaku)
		calcTier(hanTotal)				#Figures out what "Tier" of hand it is
		if(hanTotal < 5 && not isYakuman):
			if(handYaku.has('Chiitoitsu')):
				numFu = 25
			else:
				numFu = handFu()
				print("numFu: " + str(numFu))
			handScore = numFu * pow(2, (2 + hanTotal))
			if isDealer:
				handScore *= 6
			else:
				handScore *= 4
		
		handScore += (300 * scoringScript.honbaBox)
		print("HandToCalc: " + str(handToCalc))
		print("HandYaku: " + str(handYaku))
		print("-----------------------------------------------------------------------------------------------")
		
		if not handYaku.is_empty() && not handHan.is_empty():
			var i = 0
			for yaku in handYaku:
				yakuLabel.append_text(yaku + "\n")
				hanLabel.append_text(str(handHan[i]) + "\n")
				i+=1
			tierLabel.text = handTier
			scoreLabel.text = str(handScore)
		if isYakuman == true:
			for yaku in handYaku:
				yakuLabel.append_text(yaku + "\n")
			tierLabel.text = handTier
			scoreLabel.text = str(handScore)
			
	else:
		print("Need 14 tiles to calculate score!!")


func _on_calculate_pressed() -> void:
	handTier = ""
	numFu = 0
	handScore = 0
	yakuLabel.text = ""
	hanLabel.text = "" 
	tierLabel.text = "N/A"
	scoreLabel.text = "0"
	isYakuman = false
	yakuMgr.resetValues()
	if(yakuMgr.seatWind == "East"):
		isDealer = true
	else:
		isDealer = false
	getAllYaku()
