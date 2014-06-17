import mmap
import os

def drop(lst,n):
     n = n - 1
     while n >= 0:
	del lst[n]
	n -= 1
     return lst

def inversions(aList):
	inversion=0
	end = len(aList)-1
	y=1
	x=0
	while y < len(aList) :	
		if y == end:
			x += 1
			y = x + 1		
		if aList[x] > aList[y]:
			inversion+=1		
		y+=1
	return inversion
	
inv=0
chunk = 0
mfd = os.open('int.txt',os.O_RDONLY)
mfile = mmap.mmap(mfd,0,prot=mmap.PROT_READ)
size = mfile.size()
thelist = map(int,mfile.read(size).strip().split('\n'))

while len(thelist) >= 1000:
	l = thelist[:1000]
	inv += inversions(l)
	drop(thelist,1000)

print inv
