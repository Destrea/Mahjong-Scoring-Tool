@tool
extends EditorScript
#@onready var riichi_mgr = %RiichiManager

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
var testSeq4 = ['1','1','2','2','3','3','4','4','5','5','6','7','8','9'] # 5 pairs, and a sequence. Not valid, 1 pair away from being eligible for a tsumo into Chiitoitsu
var chiitoitsuHand = ['1m','1m','2m','2m','3m','3m','3p','3p','4p','4p','o','o','z','z']
var kokushiHand = ['1m','9m','1p','9p','1s','9s','9s','e','o','w','n','x','y','z']
var DaisangenHand = ['3m','3m','3m','2s','2s','0x','0x','0x','0y','0y','0y','0z','0z','0z']
var suushiiHand = ['2m','2m','0e','0e','0e','0o','0o','0o','0w','0w','0w','0n','0n','0n']
var tsuuiisouHand = ['0y','0y','0e','0e','0e','0o','0o','0o','0w','0w','0w','0z','0z','0z']
var chinroutouHand = ['1m','1m','1m','9m','9m','9m','1p','1p','1p','1s','1s','9s','9s','9s']
var ryuuiisouHand = ['2s','2s','3s','3s','4s','4s','6s','6s','6s','8s','8s','8s','0z','0z']
var chuurenHand = ['1m','1m','1m','2m','3m','4m','5m','6m','7m','8m','8m','9m','9m','9m']
#------------------------------
var melds = [""]
var temp = []
var total = 0
var rem
var testValues = []
var meldContains = {"pair" : 0, "triplet": 0, "kan": 0, "sequence" : 0}
var tile
var index
var hand = chiitoitsuHand
#var hand = chuurenHand
var yakuList = []
var handClosed = true
var currentHand = []


func _get_Suit(string):
	return string[-1]

func _get_Val(string):
	return string[0]



func tileCounter(hand):
	var counted_set = {}
	for tile in hand:
		if not counted_set.get(tile):
			counted_set[tile] = 1
		else:
			counted_set[tile] += 1
	return counted_set

func find_Yaku(hand):
	var validationVals = handValidation(hand)
	var validHand = validationVals[0]
	var handMelds = validationVals[1]
	#print("Validated Melds: " + str(handMelds))
	var currentHand = validationVals[2]
	#----------------------------------------
	# Detection for odd standard Yaku
	#----------------------------------------
	print("Detection Start:--------------------------------")
	
	var countedHand = tileCounter(currentHand)
	print("CountedHand: " + str(countedHand))
	var pairCount = 0
	for tile in countedHand:
		if countedHand.get(tile) ==2:
			pairCount +=1
		else:
			pass
			
	#Checking for Chiitoitsu
	if pairCount == 7:
		yakuList.append('Chiitoitsu')
		#print("Is a Chiitoitsu hand")
		print(yakuList)
	
	#----------------------------------------
	# Detection for Yakuman and double Yakuman
	#----------------------------------------
	
	#Checking for Kazoe yakuman (13+ han from regular yaku or dora)
	# if calculatedYaku >=13:
		#yakuList.append('Kazoe Yakuman')

	#Checking for Kokushi Musou (13 Orphans) - [1m,9m,1p,9p,1s,9s,e,o,w,n,x,y,z] and one duplicate of something
	if countedHand.has_all(['1m','9m','1p','9p','1s','9s','e','o','w','n','x','y','z']):
		if countedHand.size() == 13 && len(hand) == 14:
			yakuList.append('Kokushi Musou')
			print(yakuList)
	
	#Checking for Suuankou (Closed hand with 4 triplets)
	if handClosed == true && validHand == true && handMelds.get('triplet') == 4:
		yakuList.append('Suuankou')
		print(yakuList)
	
	#Checking for Daisangen (triplets of all 3 dragons)
	if countedHand.has_all(['x','y','z']):
		if countedHand.get('x') >= 3 && countedHand.get('y') >= 3 && countedHand.get('z') >= 3 && validHand == true:
			yakuList.append('Daisangen')
			print(yakuList)
	
	#Checking for Shousuushii (Small winds - 3 triplets and a pair of winds)
	#Checking for Daisuushii (Big Winds - 4 triplets of winds)
	if countedHand.has_all(['0e','0o','0w','0n']) && validHand == true:
		if handMelds.get("triplet") >= 3 && (countedHand.get('0e') == 2 || countedHand.get('0o') == 2 ||countedHand.get('0w') == 2 ||countedHand.get('0n') == 2):
			yakuList.append('Shousuushii')
			print(yakuList)
		elif handMelds.get("triplet") >= 3 && ( countedHand.get('0e') == 3 && countedHand.get('0o') == 3 && countedHand.get('0w') == 3 && countedHand.get('0n') == 3):
			yakuList.append('Daisuushii')
			print(yakuList)
	
	#Checking for Tsuuiisou ( All Honors) - May be open
	if validHand == true:
		print("Entered Tsuuiisou")
		var allHonors = true
		var HandKeys = countedHand.keys()
		print("HandKeys: " + str(HandKeys))
		for tile in HandKeys:
			if _get_Val(tile) == '0':
				pass
			else:
				allHonors = false
		if allHonors == true:
			yakuList.append("Tsuuiisou")
			print(yakuList)
	
	# Checking for Chinroutou (All Terminals) - May be Open
	if validHand == true:
		#print("Entered Chinroutou")
		var allTerminals = true
		var HandKeys = countedHand.keys()
		#print("HandKeys: " + str(HandKeys))
		for tile in HandKeys:
			if _get_Val(tile) == '1' || _get_Val(tile) == '9':
				pass
			else:
				allTerminals = false
		if allTerminals == true:
			yakuList.append("Chinroutou")
			print(yakuList)
			
	# Checking for Ryuuiisou (All Green) - May be Open
	if validHand == true:
		var allGreen = true
		var HandKeys = countedHand.keys()
		
		for tile in HandKeys:
			if tile == '2s' || tile == '3s' || tile == '4s' || tile == '6s' || tile == '8s' || tile == '0z':
				pass
			else:
				allGreen = false
		if allGreen == true:
			yakuList.append("Ryuuiisou")
			print(yakuList)
			
	# Checking for Chuuren Poutou (Nine Gates: A hand consisting of 1112345678999, and any other tile of the same suit) - Closed only
	if validHand == true:
		var HandKeys = countedHand.keys()
		var suitCheck = _get_Suit(HandKeys[1])
		var allSameSuit = true
		var chuurenCheck = true
		for tile in HandKeys:
			if _get_Suit(tile) == suitCheck:
				pass
			else:
				allSameSuit = false
		if allSameSuit == true:
			if suitCheck == 'm':
				if countedHand.has_all(['1m','2m','3m','4m','5m','6m','7m','8m','9m']) && countedHand.get('1m') >= 3 && countedHand.get('9m') >= 3:
					pass
				else:
					chuurenCheck = false
			if suitCheck == 'p':
				pass
			if suitCheck == 'm':
				pass
		if chuurenCheck == true:
			yakuList.append("Chuuren Poutou")
			print(yakuList)
#Take a pair at the end. If left with a pair, the hand is valid. If left with an individual piece, Tsumo tile needs to match it
func _takePair(hand, index):
	#print(hand)
	#print("Index 71: " + str(index))
	if index <= 12 && (hand[index] == hand[index+1]):
		tile = hand.pop_at(index+1)
		temp.append(tile)
		tile = hand.pop_at(index)
		temp.append(tile)
		#print("Temp: " + str(temp))
		melds.append_array(temp)
		melds.append("")
		#print("Temp: " + str(temp))
		#print("Melds: " + str(melds))
		meldContains["pair"] +=1

func _find_Meld(hand):
	#for pos in range(0,len(hand)-1):
		if len(hand) > 0:
			#pos = 0
			tile = hand[0]
			temp.clear()
			index = hand.find(tile)
			#print("Tile picked: " + str(hand[index]))
			#print("Hand: " + str(hand))
			if len(hand) == 2:
				if hand[0] == hand[1]:
					tile = hand.pop_at(0)
					temp.append(tile)
					tile = hand.pop_at(0)
					temp.append(tile)
					melds.append_array(temp)
					#meldContains["pair"] +=1
					#print("L99 Hand: " + str(hand))
					
			elif int(_get_Val(hand[index])) != int(_get_Val(hand[index+2])):#Find sequences
				#print("No triplet, checking seq")
				var TileSuit = _get_Suit(hand[index])
				var Tile2 = str(int(_get_Val(hand[index]))+1) + TileSuit
				var Tile3 = str(int(_get_Val(hand[index]))+2) + TileSuit
				var indx1 = hand.find(Tile2)
				var indx2 = hand.find(Tile3)
				if indx1 != -1 && indx2 != -1:
					tile = hand.pop_at(index)
					temp.append(tile)
					tile = hand.pop_at(indx1-1)
					temp.append(tile)
					tile = hand.pop_at(indx2-2)
					temp.append(tile)
					melds.append_array(temp)
					if len(hand) > 0:
						melds.append("")
					meldContains["sequence"] +=1
					#print("meldContains: " + str(meldContains))
					#print("Melds: " + str(melds))
					if not hand.is_empty():
						_find_Meld(hand)
			elif int(_get_Val(hand[index])) == int(_get_Val(hand[index+2])) && _get_Suit(hand[index]) == _get_Suit(hand[index+2]):
				print("Triplet Found")
				for i in range(0,3):
					tile = hand.pop_at(index)
					temp.append(tile)
				#print("Temp: " + str(temp))
				melds.append_array(temp)
				if len(hand) > 0:
					melds.append("")
				meldContains["triplet"] +=1
				print("Melds: " + str(melds))
				#print("meldContains: " + str(meldContains))
				if not hand.is_empty():
						_find_Meld(hand)
				#addCode("t")
				#meldCodes.push_back('')
				#print("L133 Hand: " + str(hand))
				#pos = 0
			
		#print("Hand:" + str(hand))
			
			
			
func handValidation(hand):
	var originalHand = hand.duplicate()
	#var nineIndex = 
	print()
	#print("Begin Dupe: --------------------------------------------------------------------------------")
	for pos in hand:
		total += int(pos)
	print(hand)
	#emojiConvert(hand)
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
		index = hand.find(str(val))
		#print("Index: " + str(index))
		#print("Test value: " + str(val))
		#print("Test Value Index: " + str(index))
		if hand.find(val) == -1:
			pass#print("This value doesnt exist in the hand: " + str(val))
		elif hand.count(hand[index]) <= 3:
			print("there are less than three, so remove a pair and try a sequence: " + str(val))
			print("Index: " + str(index))
			_takePair(hand,index)
			_find_Meld(hand)
			print("Hand: " + str(hand))
			if hand.is_empty():
				# If the hand is empty after finding melds, the algorithm theoretically worked.
				print("Hand is empty")
				temp.clear()
			else:
				# If the hand isnt empty, finding melds was unsuccessful, so we clear temp, the melds, and the meld counter
				temp.clear()
				melds.clear()
				hand = originalHand.duplicate()
				#meldContains["pair"] = 0
				meldContains["sequence"] = 0
				meldContains["kan"] = 0
				meldContains["triplet"] = 0
				print("Hand is not empty")
		else:
			#_takePair(hand,index)
			_find_Meld(hand)
			print("Melds: " + str(melds))
			print(meldContains)
		
	if not hand.is_empty():
		print("Not a valid hand")
		return [false, meldContains,originalHand]
	print("\n------------------------------")
	print("This is a valid hand! :)")
	print("Melds: " + str(melds))
	var validHand = true
	if validHand == true && meldContains["pair"] == 0:
		meldContains["pair"] = 1
	print("------------------------------")
	#meldChecker(melds)
	print("Melds: " + str(melds))
	print(meldContains)
	print("------------------------------")
	return [true, meldContains,originalHand]
	
	

func _run():
	find_Yaku(hand)
	handValidation(hand)
	meldChecker(melds)
