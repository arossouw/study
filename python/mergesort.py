# merge sort attempt
# split array in two
# sort left side, then right side
# stuck last step , sorting merged list

li = [2,9,3,8,4,1,6,7]

mid = len(li) / 2
right = li[mid:]
left = li[:mid]

def sort_smaller(n):
	sorted=[]
	if n[0] < n[len(n)-1]:
		x = n[len(n) - 1]
		y = n[0]
		n[0] = x
		n[len(n)-1] = y
		
	for i in range(0,len(n)):
		if (i + 1) < len(n):
			next=i+1
		x = n[i]
		y = n[next]
		if (x < y):
			n[next] = x
			n[i] = y
		
	for m in range(0,len(n)):
		sorted.append(n.pop())
		
	return sorted

x=sort_smaller(left)
y=sort_smaller(right)
m = len(x) / 2
a = len(y) / 2
z = x[:m] + y[:m]
q = x[m:] + y[m:]

if q[0] < z[0]:
    li = sort_smaller(q) + sort_smaller(z)
else:
    li = sort_smaller(z) + sort_smaller(q)

print li
