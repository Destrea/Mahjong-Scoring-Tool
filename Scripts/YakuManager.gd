#@tool
#extends EditorScript
extends Node

@onready var riichi_mgr = $"../RiichiManager"
@onready var scoring_mgr = $".."
#extends Node

	#TODO Implement a function for reading player hand and detecting yaku eligibility
	#----------------------------------------------------------------------------------
	# This includes detecting for sequences, triplets, kans.
	# Additionally detecting for Tsumo draw tiles, ron tiles, ciitoitsu (7 pairs) and more
	# First - create code to detect sequences
	# Second - create code to detect pairs/triplets/kans
	# Third - begin detecting for Yaku criteria based on what components are found
	
	#Resources
	#----------------------------------------------------------------------------------
	# https://github.com/MahjongRepository/mahjong/tree/master/mahjong
	# https://stackoverflow.com/questions/4154960/algorithm-to-find-streets-and-same-kind-in-a-hand
	
	
#------------------------------
# Testing Data
#------------------------------
var testSeq1 = ['1m','1m','1m','2m','2m','2m','3p','3p','3p','4p','4p','4p','5s','5s'] # 4 triplets and a pair - 111 222 333 444 55
var testSeq2 = ['1m','2m','3m','4m','5m','5m','5m','5m','6m','7m','8m','9m','9m','9m'] # 3 sets, a triplet and a pair - 123 456 789 555 99
var testSeq3 = ['1m','1m','2m','2m','3m','3m','7m','8m','8m','8m','8m','9m','9m','9m'] # 3 sets, a triplet and a pair 123 123 789 888 99

var chiitoitsuHand = ['1m','1m','2m','2m','3m','3m','3p','3p','4p','4p','o','o','0z','0z']
var kokushiHand = ['1m','9m','1p','9p','1s','9s','9s','e','o','w','n','0x','0y','0z']
var DaisangenHand = ['3m','3m','3m','2s','2s','0x','0x','0x','0y','0y','0y','0z','0z','0z']
var suushiiHand = ['2m','2m','0e','0e','0e','0o','0o','0o','0w','0w','0w','0n','0n','0n']
var tsuuiisouHand = ['0y','0y','0e','0e','0e','0o','0o','0o','0w','0w','0w','0z','0z','0z']
var chinroutouHand = ['1m','1m','1m','9m','9m','9m','1p','1p','1p','1s','1s','9s','9s','9s']
var ryuuiisouHand = ['2s','2s','3s','3s','4s','4s','6s','6s','6s','8s','8s','8s','0z','0z']
var chuurenHand = ['1m','1m','1m','2m','3m','4m','5m','6m','7m','8m','8m','9m','9m','9m']
var suukantsuHand = ['1m','1m','1m','1m','2m','2m','2m','2m','3m','3m','3m','3m','9s','9s','9s','9s','0z','0z']

var multiYakumanHand = ['0e','0e','0e','0n','0n','0x','0x','0x','0y','0y','0y','0z','0z','0z']
#------------------------------
var melds = [""]
var temp = []
var total = 0
var rem
var testValues = []
var meldContains = {"pair" : 0, "triplet": 0, "kan": 0, "sequence" : 0}
var tile
var index
var hand = multiYakumanHand
var tripletTracker = []
var pair = ""
#var hand = chuurenHand
var yakuList = []
var handClosed = true
var currentHand = []
var countedHand
var seatWind = "East"
var roundWind = "East"

var isYakuman : bool = false

@export var yakuhaiCount : int = 0

func _get_Suit(string):
	return string[-1]

func _get_Val(string):
	return string[0]

func resetValues():
	melds = [""]
	meldContains = {"pair" : 0, "triplet": 0, "kan": 0, "sequence" : 0}
	yakuList = []
	currentHand = []

func tileCounter(givenHand):
	var counted_set = {}
	for curtile in givenHand:
		if not counted_set.get(curtile):
			counted_set[curtile] = 1
		else:
			counted_set[curtile] += 1
	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2CountedSet DEBUG = " + str(counted_set))
	return counted_set


func getYakuhai(countedHand):
	yakuhaiCount = 0
	if seatWind == "East" && countedHand.has("0e"):
		if countedHand["0e"] >= 3:
			yakuhaiCount += 1
	if seatWind == "South" && countedHand.has("0o"):
		if countedHand["0o"] >= 3:
			yakuhaiCount += 1
	if seatWind == "West" && countedHand.has("0w"):
		if countedHand["0w"] >= 3:
			yakuhaiCount += 1
	if seatWind == "North" && countedHand.has("0n"):
		if countedHand["0n"] >= 3:
			yakuhaiCount += 1
	# Round Winds
	if roundWind == "East" && countedHand.has("0e"):
		if countedHand["0e"] >= 3:
			yakuhaiCount += 1
	if roundWind == "South" && countedHand.has("0o"):
		if countedHand["0o"] >= 3:
			yakuhaiCount += 1
	if countedHand.has("0x"):
		if countedHand["0x"] >= 3:
			yakuhaiCount += 1
	if countedHand.has("0y"):
		if countedHand["0y"] >= 3:
			yakuhaiCount += 1
	if countedHand.has("0z"):
		if countedHand["0z"] >= 3:
			yakuhaiCount += 1

func find_Yaku(curhand):
	var validationVals = handValidation(curhand)
	var validHand = validationVals[0]
	var handMelds = validationVals[1]
	print("Validated Melds: " + str(handMelds))
	var givenHand = validationVals[2]
	
	
	#----------------------------------------
	# Detection for odd standard Yaku
	#----------------------------------------
	print("Detection Start:--------------------------------")
	resetValues()
	countedHand = tileCounter(givenHand)
	print("CountedHand: " + str(countedHand))
	
	getYakuhai(countedHand)
	
	#Checking for Chiitoitsu
	var pairCount = 0
	for curtile in countedHand:
		if countedHand.get(curtile) == 2:
			pairCount +=1
		else:
			pass
	if pairCount == 7 && handClosed == true:
		yakuList.append('Chiitoitsu')
		#print("Is a Chiitoitsu hand")
		print(yakuList)
	elif pairCount == 7 && handClosed == false:
		validHand = false
	
	#-----------------------
	# One-Han (Closed Only)
	#-----------------------
	
	# Menzenchin Tsumohou
	if validHand == true:
		#yakuList.append('Menzenchin Tsumohou')
		pass
	
	# Riichi
	if validHand == true :# && riichi == true:
		#yakuList.append('Riichi')
		pass
	
	# Ippatsu ( Declare Riichi and win by your next tile draw )
	if validHand == true:# && ippatsuChance == true:
		#yakuList.append('Ippatsu')
		pass
	
	# Pinfu ( Closed hand that scores the minimum fu )
	if validHand == true: 
		if meldContains['sequence'] == 3 && meldContains['pair'] == 1:
			#Check for Ryanmen wait ( Two consecutive non terminal tiles waiting to complete the sequence)
			#yakuList.append('Pinfu')
			pass
	
	# Iipeikou
	if validHand == true:
		if meldContains['sequence'] >= 2:
			#Check if both sequences are the same
			#yakuList.append('Iipeikou)
			pass
	
	#-----------------------
	# One-Han 
	#-----------------------
	
	
	
	
	#----------------------------------------
	# Detection for Yakuman and double Yakuman
	#----------------------------------------
	
	#Checking for Kazoe yakuman (13+ han from regular yaku or dora)
	# if calculatedYaku >=13:
		#yakuList.append('Kazoe Yakuman')

	#Checking for Kokushi Musou (13 Orphans) - [1m,9m,1p,9p,1s,9s,e,o,w,n,x,y,z] and one duplicate of something
	if countedHand.has_all(['1m','9m','1p','9p','1s','9s','0e','0o','0w','0n','0x','0y','0z']):
		if countedHand.size() == 13 && len(hand) == 14:
			yakuList.append('Kokushi Musou')
			print(yakuList)
			isYakuman = true
	
	#Checking for Suuankou (Closed hand with 4 triplets)
	if handClosed == true && validHand == true && handMelds.get('triplet') == 4:
		yakuList.append('Suuankou')
		print(yakuList)
	elif handClosed == false && validHand == true && handMelds.get('triplet') == 4:
		yakuList.append('Toitoi')
		print(yakuList)
		isYakuman = true
	
	#Checking for Daisangen (triplets of all 3 dragons)
	if countedHand.has_all(['0x','0y','0z']):
		if countedHand.get('0x') >= 3 && countedHand.get('0y') >= 3 && countedHand.get('0z') >= 3 && validHand == true:
			yakuList.append('Daisangen')
			print(yakuList)
			isYakuman = true
	
	#Checking for Shousuushii (Small winds - 3 triplets and a pair of winds)
	#Checking for Daisuushii (Big Winds - 4 triplets of winds)
	if countedHand.has_all(['0e','0o','0w','0n']) && validHand == true:
		if handMelds.get("triplet") >= 3 && (countedHand.get('0e') == 2 || countedHand.get('0o') == 2 ||countedHand.get('0w') == 2 ||countedHand.get('0n') == 2):
			yakuList.append('Shousuushii')
			print(yakuList)
		elif handMelds.get("triplet") >= 3 && ( countedHand.get('0e') == 3 && countedHand.get('0o') == 3 && countedHand.get('0w') == 3 && countedHand.get('0n') == 3):
			yakuList.append('Daisuushii')
			print(yakuList)
			isYakuman = true
	
	#Checking for Tsuuiisou ( All Honors) - May be open
	if validHand == true:
		print("Entered Tsuuiisou")
		var allHonors = true
		var HandKeys = countedHand.keys()
		print("HandKeys: " + str(HandKeys))
		for curtile in HandKeys:
			if _get_Val(curtile) == '0':
				pass
			else:
				allHonors = false
		if allHonors == true:
			yakuList.append("Tsuuiisou")
			print(yakuList)
			isYakuman = true
	
	# Checking for Chinroutou (All Terminals) - May be Open
	if validHand == true:
		#print("Entered Chinroutou")
		var allTerminals = true
		var HandKeys = countedHand.keys()
		#print("HandKeys: " + str(HandKeys))
		for curtile in HandKeys:
			if _get_Val(curtile) == '1' || _get_Val(curtile) == '9':
				pass
			else:
				allTerminals = false
		if allTerminals == true:
			yakuList.append("Chinroutou")
			print(yakuList)
			isYakuman = true
			
	# Checking for Ryuuiisou (All Green) - May be Open
	if validHand == true:
		var allGreen = true
		var HandKeys = countedHand.keys()
		
		for curtile in HandKeys:
			if curtile == '2s' || curtile == '3s' || curtile == '4s' || curtile == '6s' || curtile == '8s' || curtile == '0z':
				pass
			else:
				allGreen = false
		if allGreen == true:
			yakuList.append("Ryuuiisou")
			print(yakuList)
			isYakuman = true
			
	# Checking for Chuuren Poutou (Nine Gates: A hand consisting of 1112345678999, and any other tile of the same suit) - Closed only
	if validHand == true && handClosed == true:
		var HandKeys = countedHand.keys()
		var suitCheck = _get_Suit(HandKeys[1])
		var allSameSuit = true
		var chuurenCheck = false
		for curtile in HandKeys:
			if _get_Suit(curtile) == suitCheck:
				pass
			else:
				allSameSuit = false
		if allSameSuit == true:
			if suitCheck == 'm':
				if countedHand.has_all(['1m','2m','3m','4m','5m','6m','7m','8m','9m']) && countedHand.get('1m') >= 3 && countedHand.get('9m') >= 3:
					chuurenCheck = true
				else:
					pass
			if suitCheck == 'p':
				if countedHand.has_all(['1p','2p','3p','4p','5p','6p','7p','8p','9p']) && countedHand.get('1p') >= 3 && countedHand.get('9p') >= 3:
					chuurenCheck = true
				else:
					pass
			if suitCheck == 'm':
				if countedHand.has_all(['1s','2s','3s','4s','5s','6s','7s','8s','9s']) && countedHand.get('1s') >= 3 && countedHand.get('9s') >= 3:
					chuurenCheck = true
				else:
					pass
		if chuurenCheck == true:
			yakuList.append("Chuuren Poutou")
			print(yakuList)
			isYakuman = true
			
			
	#var kanCount = 0
	#pairCount = 0
	#for curtile in countedHand:
	#	print("Entered Suukantsu")
	#	if countedHand.get(curtile) == 4:
	#		kanCount +=1
	#		print("KanCount: "+ str(kanCount))
	#	elif countedHand.get(curtile) == 2:
	#		pairCount += 1
	#Checking for Suukantsu
	#if kanCount == 4 && pairCount == 1:
	#	yakuList.append('Suukantsu')
	#	#print("Is a Chiitoitsu hand")
	#	print(yakuList)
	
	# Chinitsu / Honitsu
	if validHand == true && isYakuman == false:
		var HandKeys = countedHand.keys()
		var tileSuit = _get_Suit(HandKeys[1])
		var chinitsu = true
		var honitsu = true
		for curtile in HandKeys:
			if _get_Suit(curtile) == tileSuit:
				pass
			else:
				chinitsu = false
				if _get_Suit(curtile) == "m" || _get_Suit(curtile) == "p" ||_get_Suit(curtile) == "s":
					honitsu = false
					break
			
		if chinitsu == true:
			yakuList.append("Chinitsu")
			print(yakuList)
		elif honitsu == true:
			yakuList.append("Honitsu")
			print(yakuList)
	
	
	#Honroutou
	if validHand == true:
		var allTerminals = true
		var HandKeys = countedHand.keys()
		var tileval;
		for curtile in HandKeys:
			tileval = _get_Val(curtile)
			if tileval == "1" || tileval == "0" || tileval == "9":
				pass
			else:
				allTerminals = false
				break
		if allTerminals == true:
			yakuList.append("Honroutou")
			print(yakuList)
	
	# Sanankou
	if handClosed == true && validHand == true && handMelds.get('triplet') == 3:
		yakuList.append('Sanankou')
		print(yakuList)
	
	# Tanyao
	if validHand == true:
		var handKeys = countedHand.keys()
		var tanyaoCheck = true
		for curTile in handKeys:
			if _get_Val(curTile) == "0" || _get_Val(curTile) == "9" ||_get_Val(curTile) == "1":
				tanyaoCheck = false
				break
			else:
				pass
			
		if tanyaoCheck == true:
			yakuList.append("Tanyao")
			print(yakuList)
	

#Take a pair at the end. If left with a pair, the hand is valid. If left with an individual piece, Tsumo tile needs to match it
func _takePair(inputHand, inputIndex):
	#print(hand)
	print("Index 71: " + str(index))
	if inputHand.size() > 0 && index <= 12 && (inputHand[inputIndex] == inputHand[inputIndex+1]):
		tile = inputHand.pop_at(inputIndex+1)
		temp.append(tile)
		tile = inputHand.pop_at(inputIndex)
		temp.append(tile)
		#print("Temp: " + str(temp))
		melds.append_array(temp)
		melds.append("")
		#print("Temp: " + str(temp))
		#print("Melds: " + str(melds))
		meldContains["pair"] +=1
		pair = tile

func _find_Meld(inputHand):
	for pos in range(0,len(hand)-1):
		var curCounts = tileCounter(inputHand)
		if len(inputHand) > 0:
			pos = 0
			tile = inputHand[0]
			temp.clear()
			index = inputHand.find(tile)
			#print("Tile picked: " + str(hand[index]))
			#print("Hand: " + str(hand))
			if len(inputHand) == 2 :
				if inputHand[0] == inputHand[1]:
					tile = inputHand.pop_at(0)
					temp.append(tile)
					tile = inputHand.pop_at(0)
					temp.append(tile)
					melds.append_array(temp)
					pair = tile
					print("pair = " + str(pair))
					meldContains["pair"] += 1
					#print("L99 Hand: " + str(hand))
			elif curCounts[tile] == 2:
				tile = inputHand.pop_at(0)
				temp.append(tile)
				tile = inputHand.pop_at(0)
				temp.append(tile)
				melds.append_array(temp)
				pair = tile
				print("pair = " + str(pair))
			elif int(_get_Val(inputHand[index])) == int(_get_Val(inputHand[index+2])) && _get_Suit(inputHand[index]) == _get_Suit(inputHand[index+2]):
				print("Triplet Found")
				for i in range(0,3):
					tile = inputHand.pop_at(index)
					temp.append(tile)
				#print("Temp: " + str(temp))
				melds.append_array(temp)
				if len(inputHand) > 0:
					melds.append("")
				meldContains["triplet"] +=1
				tripletTracker.append(tile);
				print("Melds: " + str(melds))
				#print("meldContains: " + str(meldContains))
				if not inputHand.is_empty():
						_find_Meld(inputHand)
				#addCode("t")
				#meldCodes.push_back('')
				#print("L133 Hand: " + str(hand))
				pos = 0
			
			elif int(_get_Val(inputHand[index])) != int(_get_Val(inputHand[index+2])):#Find sequences
				#print("No triplet, checking seq")
				var TileSuit = _get_Suit(inputHand[index])
				var Tile2 = str(int(_get_Val(inputHand[index]))+1) + TileSuit
				var Tile3 = str(int(_get_Val(inputHand[index]))+2) + TileSuit
				var indx1 = inputHand.find(Tile2)
				var indx2 = inputHand.find(Tile3)
				if indx1 != -1 && indx2 != -1:
					tile = inputHand.pop_at(index)
					temp.append(tile)
					tile = inputHand.pop_at(indx1-1)
					temp.append(tile)
					tile = inputHand.pop_at(indx2-2)
					temp.append(tile)
					melds.append_array(temp)
					if len(inputHand) > 0:
						melds.append("")
					meldContains["sequence"] +=1
					#print("meldContains: " + str(meldContains))
					#print("Melds: " + str(melds))
					if not inputHand.is_empty():
						_find_Meld(inputHand)
		#print("Hand:" + str(hand))

func handValidation(inputHand):
	var originalHand = inputHand.duplicate()
	total = 0
	#print("Begin Dupe: --------------------------------------------------------------------------------")
	for pos in inputHand:
		total += int(pos)
	print(inputHand)
	print("------------------------------")
	print("total: " + str(total))
	rem = total % 3
	print("Rem: " + str(rem))
	
	if rem == 0:
		testValues = ['3m','6m','9m','3p','6p','9p','3s','6s','9s','0e','0o','0w','0n','0x','0y','0z']
		print("M = {3,6,9} in any suit")
	elif rem == 1:
		testValues = ['2m','5m','8m','2p','5p','8p','2s','5s','8s','0e','0o','0w','0n','0x','0y','0z']
		print("M = {2,5,8} in any suit")
	elif rem == 2:
		testValues = ['1m','4m','7m','1p','4p','7p','1s','4s','7s','0e','0o','0w','0n','0x','0y','0z']
		print("M = {1,4,7} in any suit")
	print("------------------------------\n\n")
	for val in testValues:
		temp.clear()
		index = inputHand.find(str(val))
		print("Index: " + str(index))
		print("Test value: " + str(val))
		print("Test Value Index: " + str(index))
		
		
		if inputHand.find(val) == -1:
			pass#print("This value doesnt exist in the hand: " + str(val))
		elif inputHand.count(inputHand[index]) <= 3:
			print("there are less than three, so remove a pair and try a sequence: " + str(val))
			print("Index: " + str(index))
			_find_Meld(inputHand)
			print("Hand: " + str(inputHand))
			if inputHand.is_empty():
				# If the hand is empty after finding melds, the algorithm theoretically worked.
				print("Hand is empty")
				temp.clear()
			else:
				# If the hand isnt empty, finding melds was unsuccessful, so we clear temp, the melds, and the meld counter
				temp.clear()
				melds.clear()
				inputHand = originalHand.duplicate()
				meldContains["pair"] = 0
				meldContains["sequence"] = 0
				meldContains["kan"] = 0
				meldContains["triplet"] = 0
				print("Hand is not empty")
		else:
			_takePair(inputHand,index)
			_find_Meld(inputHand)
			print("Melds: " + str(melds))
			print(meldContains)
		
	if not inputHand.is_empty():
		print("Not a valid hand")
		return [false, meldContains,originalHand]
	print("\n------------------------------")
	print("This is a valid hand! :)")
	print("Melds: " + str(melds))
	
	
	#if validHand == true && meldContains["pair"] == 1:
	#	meldContains["pair"] = 1
	print("------------------------------")
	#meldChecker(melds)
	print("Melds: " + str(melds))
	print(meldContains)
	print("TripletTracker: " + str(tripletTracker))
	print("Pair: " + str(pair))
	print("------------------------------")
	return [true, meldContains,originalHand]

func _run():
	find_Yaku(hand)
	handValidation(hand)
	#meldChecker(melds)

func _ready():
	pass
