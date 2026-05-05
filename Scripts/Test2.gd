@tool
extends EditorScript

var testSeq2 = ['1','2','3','4','5','5','5','5','6','7','8','9','9','9'] # 3 sets, a triplet and a pair - 123 456 789 555 99
var hand = testSeq2

var count_set = {}
var working_set = {}
#Placeholder shit
var sets_formed
var pair_formed = false

var melds = {"pair" : 0 , "sequence": 0, "triplet" : 0}
var groupings = [[],[],[],[],[],[],[]]

var i = 0

func tileCounter(hand):
	for tile in hand:
		if not count_set.has(tile):
			count_set[tile] = hand.count(tile)
	
func checkTriSeq(working_set):
	#Checking for Triplets
	for tile in working_set:
		if working_set.get(tile) >=3 && i <5:
			groupings[i] = [tile,tile,tile]
			i+=1
			print("Working_set: " + str(working_set))
			working_set[tile] -=3
			if working_set[tile] == 0:
				working_set.erase(tile)
			print("Working_set: " + str(working_set))
			
	for tile in working_set:
		var first = tile
		var second = int(tile)+1
		var third = int(tile)+2		
		if working_set.has(first) && working_set.has(str(second)) && working_set.has(str(third)):
			if working_set.has(first) && working_set.has(str(second)) && working_set.has(str(third)) && i <5:
				groupings[i] = [first,second,third]
				melds["sequence"] +=1
				working_set[tile] -=1
				working_set[str(second)] -=1
				working_set[str(third)] -=1
				if working_set[tile] == 0:
					working_set.erase(tile)
				if working_set[str(second)] == 0:
					working_set.erase(str(second))
				if working_set[str(third)] == 0:
					working_set.erase(str(third))
				i+=1
			
func handChecker(count_set):
	working_set = count_set.duplicate()
	for tile in working_set:
		if not pair_formed:
			if working_set.get(tile) >= 2 && i <5:		#Find a pair in working_set
				print("Working_set: " + str(working_set))
				working_set[tile] -=2
				print("Working_set: " + str(working_set))
				groupings[0] = [tile,tile]
				melds["pair"] +=1
				print("groupings: " + str(groupings))
				print("Melds: " + str(melds))
				i +=1
				pair_formed = true
				checkTriSeq(working_set)
				if not working_set.is_empty():
					melds["pair"] =0
					melds["triplet"] =0
					melds["sequence"] =0
					groupings[0] = []
					working_set = count_set.duplicate()
					i=0



func _run():
	tileCounter(hand)
	print(count_set)
	handChecker(count_set)
	print("Final --------------------------------")
	print("Working_set: " + str(working_set))
	print("groupings: " + str(groupings))
	print("Melds: " + str(melds))
