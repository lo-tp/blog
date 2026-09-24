---
title: '[LeetCode 233, AC] Number of Digit One Done With DP'
date: 2020-05-25T19:39:16
tags: [LeetCode, Algorithm, DP]
---
    Given an integer n, count the total number of digit 1 appearing in all non-negative integers less than or equal to n.

    Example:

    Input: 13
    Output: 6 
    Explanation: Digit 1 occurred in the following numbers: 1, 10, 11, 12, 13.
Let's try to solve [this problem](https://leetcode.com/problems/number-of-digit-one/) by dividing it into smaller quizzes:

For example, to caculate the result for 2954:
- count(2954)=count(2000)+count(954)
- count(954)=count(900)+count(54)
- count(54)=count(50)+count(4)
 
Now we got the conclusion that `count(2954)=count(2000)+count(900)+count(50)+count(4)`, which is leading us to the question of how to get `count(i*10^j)`

To calculate `count(i*10^j)`, we separate the '1's we are looking for into two groups:
- 1s appearing in the highest digit, like the first '1' in the number 1111.
    - For numbers starting with 1, this part is the lower part number plus one. Let's take 1599 as an example. From 1000 to 1599 we got 599+1=600 '1's at the highest digit.
    - For numbers not starting with 1, this part is always `10^math.floor(log10(number))`. Like for 2000, from 1000 to 1999 we got 1000 '1' which is equal to 10^3. 
- 1s appearing in the lower digits, like the last 3 '1's in the number 1111.
    The formula to calulate this part is: `(highest digit) * count(10^math.floor(log10(number)-1))`. Like for 3000, the result is 3*count(999)

At this point, the last puzzle we need to solve is to find a way to calculate count(10^n-1). Let's take a look at some examples:
- For number ranging from 1-99 we got 1 one.
- For number ranging from 1-999 we got 20 ones.
- For number ranging from 1-9999 we got 300 ones.
 
After some observations, we can see `count(10^n-1)=count(10^(n-1)-1)*10+10^(n-1)`. Combining this with an initial case of `count(9)=1`, we can extrapolate that `count(10^n-1)=n*10^(n-1)`.

With all these deductions in mind, we can finally solve the original problem with DP.
I implemente this idea with the help of stack to avoid recursion and below is the code

```python
from math import log10

class Solution(object):
    def countDigitOne(self, n):
        if n <= 0:
            return 0
        ord_0, res, t = ord('0'), 0, [
            (i+1)*10**i for i in xrange(0, int(log10(n)))]
        while n:
            te, tem = list(str(n)), int(log10(n))-1
            tmp, te[0] = ord(te[0])-ord_0, '0'
            n = int(''.join(te))
            if tem >= 0:
                res += tmp*t[tem]
                res += n+1 if tmp == 1 else 10**(tem+1)
            else:
                res += 1
        return res

```
