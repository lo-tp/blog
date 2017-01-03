---
title: '[LeetCode 417, AC] Pacific Atlantic Water Flow'
date: 2016-12-13 14:22:33
tags:
- LeetCode 
- DFS
- Bit Operation
---
Given an m x n matrix of non-negative integers representing the height of each unit cell in a continent, the "Pacific ocean" touches the left and top edges of the matrix and the "Atlantic ocean" touches the right and bottom edges.

Water can only flow in four directions (up, down, left, or right) from a cell to another one with height equal or lower.

Find the list of grid coordinates where water can flow to both the Pacific and Atlantic ocean.

**Note:**

1. The order of returned grid coordinates does not matter.
1. Both m and n are less than 150.

#### Example:
```
Given the following 5x5 matrix:

  Pacific ~   ~   ~   ~   ~ 
       ~  1   2   2   3  (5) *
       ~  3   2   3  (4) (4) *
       ~  2   4  (5)  3   1  *
       ~ (6) (7)  1   4   5  *
       ~ (5)  1   1   2   4  *
          *   *   *   *   * Atlantic

Return:

[[0, 4], [1, 3], [1, 4], [2, 2], [3, 0], [3, 1], [4, 0]] (positions with parentheses in above matrix).
```
--------------
If you try to do a DFS or BFS on each grid to see if it can reach both Pacific and Atlantic ocean, you will get a time out error.

Luckily, we can solve this problem if we think in a contrary way.
We can deduce which grids can reach Atlantic ocean and which can reach Pacific ocean, then the intersection of the two set is the answer.

In this way, the number of iterations can be greatly reduced to the sum of of the 4 edges' grids, thus averting the time out error.

It's straightforward to use two vectors to separately store the connectivities of Atlantic ocean and Pacific ocean, but there is an optimization with which you only need one vector to store the same data.That is bit mask( All credits belong to [zyoppy008][bitMastPost]).
Since the data we are trying to maintain are basically two boolean states, two bits in one int are totally enough.

```c++
#include <vector>
#include <stack>
#include <iostream>
#include <climits>

using namespace std;

class Solution
{

public:

  vector<pair<int, int>> pacificAtlantic(vector<vector<int>>& matrix)
  {
    vector<pair<int, int> > ret;
    stack <pair<int, int> > s1;
    stack <pair<int, int> > s2;
    vector <vector<int> > intermidiate;
    int hSize, vSize;
    vSize = matrix.size();
    if (vSize)
    {
      hSize = matrix[0].size();
      if (hSize)
      {
        intermidiate.resize(vSize, vector<int>(hSize, 0));
        for (int index = 0; index < vSize; index++)
        {
          s1.push(pair<int, int>(index, 0));
          s2.push(pair<int, int>(1, INT_MIN));
          s1.push(pair<int, int>(index, hSize - 1));
          s2.push(pair<int, int>(2, INT_MIN));
        }
        for (int index = 0; index < hSize; index++)
        {
          s1.push(pair<int, int>(0, index));
          s2.push(pair<int, int>(1, INT_MIN));
          s1.push(pair<int, int>(vSize - 1, index));
          s2.push(pair<int, int>(2, INT_MIN));
        }
        while (!s1.empty())
        {
          pair<int, int> pos = s1.top(), meta = s2.top();
          int vPos = pos.first, hPos = pos.second, previousValue = meta.second, flag = meta.first;
          s1.pop();
          s2.pop();
          if (vPos >= 0 && vPos < vSize && hPos >= 0 && hPos < hSize && matrix[vPos][hPos] >= previousValue &&
              (intermidiate[vPos][hPos]&flag) == 0)
          {
            intermidiate[vPos][hPos] = intermidiate[vPos][hPos] | flag;
            if (intermidiate[vPos][hPos] == 3)
            {
              cout << vPos << ' ' << hPos << endl;
              ret.push_back(pos);
            }
            s1.push(pair<int, int>(vPos - 1, hPos));
            s2.push(pair<int, int>(flag, matrix[vPos][hPos]));
            s1.push(pair<int, int>(vPos + 1, hPos));
            s2.push(pair<int, int>(flag, matrix[vPos][hPos]));
            s1.push(pair<int, int>(vPos, hPos - 1));
            s2.push(pair<int, int>(flag, matrix[vPos][hPos]));
            s1.push(pair<int, int>(vPos, hPos + 1));
            s2.push(pair<int, int>(flag, matrix[vPos][hPos]));
          }
        }
      }
    }
    return ret;
  }

};
int main()
{
  vector <vector<int> > testData = {{1, 2, 2, 3, 5}, {3, 2, 3, 4, 4}, {2, 4, 5, 3, 1}, {6, 7, 1, 4, 5}, {5, 1, 1, 2, 4}};
  Solution s;
  s.pacificAtlantic(testData);
  return 0;
}
```
[bitMastPost]:https://discuss.leetcode.com/topic/62314/very-concise-c-solution-using-dfs-and-bit-mask
