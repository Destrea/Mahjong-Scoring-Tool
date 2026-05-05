#@tool
extends Node
#extends EditorScript
class_name RiichiManager
var wall = [] #Initialze the wall and hands as empty
var hands = [['','','','','','','','','','','','',''],['','','','','','','','','','','','',''],['','','','','','','','','','','','',''],['','','','','','','','','','','','','']]


var suits = {"man": "m" , 
		 	"pin" : "p", 
		 	"sou": "s"}

var honors = {"north" : "n",
		  "east" : "e",
		  "south" : "o",
		  "west" : "w",
		  "red" : "x",
		  "white" : "y",
		  "green" : "z"}

@export var sortingKey = {"m": 0 , 
				"p" : 1, 
				"s" : 2,
				"e" : 3,
				"o" : 4,
				"w" : 5,
				"n" : 6,
				"x" : 7,
				"y" : 8,
				"z" : 9}


#var emojiKey = {"1m" : "🀇"}

#Cycles through each suit, populating the wall with pieces 1-9, with a signifier tag for which suit it is
# Then cycles through the honor suits and labels each tile 0-3 with its signifying suit tag
# TO-DO - Implement Aka Dora tiles for each of the 3 numbered suits

func _fill_wall_4P():
	var tile = ""
	for pos in suits: 										# Three suits
		var addedYaku = false
		for j in range(1,10):								# 1-9 for each suit
			for k in range(1,5):							# 4 of each number
				if j == 5 and addedYaku == false:			#The first 5 of each suit is generated as an aka-dora
					tile = str(j) + "*" + suits.get(pos)
					wall.append(tile)
					addedYaku = true						#Sets to true, disabling the aka dora generation. This bool gets reset with each suit
				else:
					tile = str(j) + suits.get(pos) 			# creates a string of the number, followed by the suit code. (ex. 7m being 7-man, 3p being 3-pin and 9s being 9-sou )
					wall.append(tile)
	for pos in honors:
		for j in range(0,4):
			tile = honors.get(pos)
			wall.append(tile)

#Cycles 3 times, dealing 4 pieces to each player each cycle, drawing from the top of the stack
# Then it cycles one time to each player, dealing 1 more tile, for 13 total for each player, leaving an empty 14th space for the draw tile
func _deal_Four():
	var playerPos = 0
	var curPos = 0
	var tile = ""
	
	for cycles in range (0,3):
		playerPos = 0
		for player in hands:
			curPos = (cycles * 4)
			for i in range (0,4):
				tile = wall.pop_back()
				hands[playerPos][curPos] = tile
				curPos += 1
			playerPos += 1
	for player in hands:
		curPos = 12
		for pPos in range (0,4):
			tile = wall.pop_back()
			hands[pPos][curPos] = tile

# Fisher-Yates algorithm to shuffle the wall's tiles, to a more effective "randomness" over the shuffle() function
func wallShuffle(wallList):
	var n = len(wallList) - 1
	var randIndex
	var temp
	while n > 0:
		randIndex = randi_range(0,n)
		temp = wallList[n]
		wallList[n] = wallList[randIndex]
		wallList[randIndex] = temp
		n -= 1

# Returns the last letter of the string passed
func _get_Last(string):
	return string[-1]

# Returns the first letter of the string passed
func _get_First(string):
	return string[0]

func sortHandSuits(hand, n):
	# Recursive Insertion sort, to sort the hand suits by "value" using the sorting key dict above
	var last = 0
	var j = 0
	if n <= 1:
		return
	
	sortHandSuits(hand,n-1)
	last = hand[n-1]
	j=n-2

	while (j>=0 and sortingKey.get(_get_Last(hand[j])) > sortingKey.get(_get_Last(last))):
		hand[j+1] = hand[j]
		j=j-1

	hand[j+1] = last

func sortHandNums(hand):
	#Check first suit. If next item matches, compare values, and sort. Continue until reaching a new suit
	var slength = 0
	var sStart = 0
	var suitSlice = []
	var tileSuit = ''
	var curSuit = ''
	for i in suits:
		curSuit = suits.get(i)
		for j in range(sStart,len(hand)):     #Iterate through player hand. Compare the tile suit against the current suit
			tileSuit = _get_Last(hand[j])
			if tileSuit == curSuit:
				slength +=1
			else:
				pass
		suitSlice = hand.slice(sStart,slength)
		suitSlice.sort()
		for k in range(0,len(suitSlice)):
			hand[sStart+k] = suitSlice[k]
		sStart = slength
		
		
func sortHands(hand,n):
	var curHand
	for i in range(0,len(hand)):
		curHand = hand[i]
		sortHandSuits(curHand,n)
		sortHandNums(curHand)

func sortOneHand(hand,n):
	sortHandSuits(hand,n)
	sortHandNums(hand)

func printHands(hand):
	for i in range(0,len(hand)):
		print(hand[i])
		print()

func _run():
	_fill_wall_4P()
	print("wall Before: \n" + str(wall))
	wallShuffle(wall)
	print("wall After: \n" + str(wall))
	_deal_Four()
	print("Unsorted hands: \n")
	printHands(hands)
	print("Sorted hands: \n")
	sortHands(hands,13)
	printHands(hands)
	
	
	
	
	# Testing 
	
	#var testHand = ['1m','5m','3m','7m','1m','5p','3p','6s','1s']
	#print("\nUnsorted Hand: " + str(testHand))
	#sortHandSuits(testHand,13)
#	sortHandNums(testHand,13)
#	print("Sorted Hand: " + str(testHand))


#for easy conversion of hand into Emoji, until I can create sprites for tiles
func emojiConv(hand):
	var convHand = ['','','','','','','','','','','','','','']
	
	#for item in hand:
	#	if item = '1p'

func _ready():
	pass
