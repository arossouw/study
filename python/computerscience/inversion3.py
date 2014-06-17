def inversions(aList):
	if not aList or type(aList) == type(1):
		return 0
	else:
		inversion=0
		end = len(aList)-1
		y=1
		x=0

	if aList[0] > aList[end]:
	     inversion+=1

	if len(aList) == 1:
	     return aList
	else:
	     while y <= end :	
		if y == end:
	 	   x += 1
		   if (x + 2) <= end:
		        y = x + 1		
	 	   if x == end and aList[x] > aList[end]:
			inversion+=1
	  	if aList[x] > aList[y]:
			inversion+=1		
		y+=1
	return inversion
	
print inversions([1,0,1,0])
