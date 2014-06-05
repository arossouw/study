#!/usr/bin/python
# recursive function for factorial
# factorial example:  4! = 4 * 3 * 2 * 1 = 24
def factorial(n):
      if n == 0:
         return 1
      return n * factorial(n-1)

print factorial(4)
