"""
# do I correctly initialize and handle empty input?
Input: {}
expected Output: 0

# do I correctly handle odd-sized input?
I: {0}
O: 0

I: {4294967295} -- try using your max int value
O: 0

# do I correclty handle even-size input?
I: {0, 0}
O: 0

# do I detect basic case of split inversion?
I: {1, 0}
O: 1

# do I actually count the split inversions?
I: {1, 1, 0}
O: 2

# do I accumulate left-inversions?
I: {1, 0, 1, 1}
O: 1

# do I accumulate right-inversions?
I: {0, 0, 1, 0}
O: 1

# do I accumulate split-inversions together with sub-problem results?
I: {1, 0, 1, 0}
O: 3
"""

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
