from collections import Counter



def winningHandRec(count_set,sets_formed=0,pair_formed=False):
    
    #Check for four sets and a pair. 
    if sets_formed == 4 and pair_formed == True:
        return True
    
    # If no pair yet, check for a pair.
    # If pair_formed = False, try to form a pair.
    # Recursively call this function with the new count_set and pair_formed as True
    # If none of the pair attempts work return false

    if not pair_formed:
        for tile, count in count_set.items():
            if count >=2:
                new_count_set = count_set.copy()
                new_count_set[tile] -=2
                if new_count_set[tile] == 0:
                    del new_count_set[tile]
                if winningHandRec(new_count_set,sets_formed,True):
                    return True
        return False
    
    for tile, count in count_set.items():
        if count >= 3:
            new_count_set = count_set.copy()
            new_count_set[tile] -=3
            if new_count_set[tile] == 0:
                del new_count_set[tile]
            if winningHandRec(new_count_set,sets_formed,True):
                    return True
    
    unique_tiles = sorted(tile for tile in count_set if count_set[tile] > 0)
    for i in range(len(unique_tiles) - 2):
        first, second, third = unique_tiles[i], unique_tiles[i+1],unique_tiles[i+2]
        if (count_set[first] > 0 and count_set[second] > 0 and count_set[third] > 0) and (second == first+1 and third == first+2):
            new_count_set = count_set.copy()
            new_count_set[first] -=1
            new_count_set[second] -=1
            new_count_set[third] -=1
            for tile in [first, second,third]:
                if new_count_set[tile] == 0:
                    del new_count_set[tile]
            if winningHandRec(new_count_set,sets_formed+1,pair_formed):
                    return True
        else:
             return False
    return False

tiles = [1,1,2,2,2,3,3,3,4,5,5,6,7,8]
count_set = Counter(tiles)

result = winningHandRec(tiles)
print(result)