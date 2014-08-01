
inversion = 0


def merge(aList):
    if not aList or type(aList) == type(1) or len(aList) == 1:
	return 0
    if len(aList) > 1:
        mid = len(aList) / 2
        left = aList[:mid]
        right = aList[mid:]
        merge(left)
        merge(right)

        left_length = len(left)
        right_length = len(right)

        i = 0
        j = 1
        k = 0

        global inversion
	split = 0

        while i < left_length and k < right_length:
	    if left[i] == right[k]:
		split = 1   # is an equal list element count split-inversion
		break
	    if left[i] > right[k]:
                inversion += 1
                k += 1
                j += 1
            else:
                i += 1
                j += 1

        k = 1
        i = 0
	if left_length == right_length and split:
	     while i < left_length and k < right_length:
		   if left[i] > right[k]:
			inversion+=1
		   k+=1
		   j+=1
	    

        return inversion

print merge([1,0,0,0])
