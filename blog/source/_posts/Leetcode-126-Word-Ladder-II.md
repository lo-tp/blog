---
title: '[LeetCode 126, TLE] Word Ladder II'
date: 2016-11-26 09:39:16
tags:
- LeetCode 
- Bfs
- Algorithm
---
If you come here for a solution to the problem, you are in a wrong place.
Because **my code for this quiz wasn't accepted yet** and the purpose of this post is to make a summary about what I have learnt about BFS from doing this exercise.
I will share my code at the end of this post and any ideas on where my code is wrong would be greatly appreciated.

##### When Should We Use BFS
When the target is to find the shortest path,BFS is a good choice.
If you do not have to find all the shortest paths, then you can stop whenever the first path is found.
Otherwise you would have to wait until all the nodes from current layer are processed.

##### How to Implement BFS
Use a queue to store the tree, and take advantage of the FIFO characteristic of queue to implement BFS.

##### Optimizations You May Want To Use With BFS
1. Use [adjacency matrix][am] to store the relationships between nodes so you only has to do this calculation once.
1. Save the length of the first path you found, whenever the depth of another path is larger than it, you can safely ignore that path.
1. Save all the nodes of current layer and remove them when depth increasing to improve efficiency of further searches.

#####  A Mistake You May Make When Using BFS
Possibility exists that you may include paths that are longer than the shortest ones in your result set so do a filter to get rid of them.
Luckily, you only need to take care of this when you are required to find all the shortest paths.

##### Lessons I Have Learnt about Javascript
1. The Right Way to Check the Existence of an Element Within an Array
I used `!array.findIndex(element !== target)` to check if target is not in array , but this was wrong when target is the first element of array.
The right way is to use `array.findIndex(element !== target)===undefined`.

1. A Fast Way to Get the Last Element of an Array
`array.slice(-1)[0]`.

----
Here comes the code, I have no idea which part is wrong...lol.

```javascript
function Queue(first) {
  this.queue = [{
    path: [0],
    word: first,
  }];
}

Queue.prototype.enque = function (elements) {
  this.queue = this.queue.concat(elements);
};

Queue.prototype.dequeue = function () {
  return this.queue.pop();
};

const getDifferenceNum = (source, target) => {
  const ret = source.filter((s, i) => s !== target[i]).length;
  return ret;
};

function Test(begin, end, list) {
  this.results = [];
  this.list = [begin, ...list];
  this.list = this.list.map(s => s.split(''));
  this.end = end.split('');
  this.queue = new Queue(begin.split(''));
  this.deep = Number.MAX_SAFE_INTEGER;
  this.removeRepitition();
  this.makeAdjacencyMatrix();
  this.currentLevel = 0;
  this.currentLevelElements = [];
  this.usedElements = [];
}

Test.prototype.makeAdjacencyMatrix = function () {
  const length = this.list.length;
  this.adjacency = [];
  let index = 0;
  while (index < length) {
    this.adjacency[index] = [];
    index += 1;
  }

  index = 0;
  while (index < length) {
    let innerIndex = index + 1;
    while (innerIndex < length) {
      if (getDifferenceNum(this.list[index], this.list[innerIndex]) === 1) {
        // making use of the symmetry of the adjacency matrix
        this.adjacency[index].push(innerIndex);
        this.adjacency[innerIndex].push(index);
      }

      innerIndex += 1;
    }

    index += 1;
  }
};

Test.prototype.removeRepitition = function () {
  const hash = {};
  const newList = [];
  this.list.forEach(l => {
    if (!hash[l]) {
      hash[l] = true;
      newList.push(l);
    }
  });
  this.list = newList;
};

Test.prototype.findChildren = function (parent) {
  const currentIndex = parent.path.slice(-1)[0];
  if (parent.path.length > this.currentLevel) {
    this.usedElements = this.usedElements.concat(this.currentLevelElements);
    this.currentLevelElements = [currentIndex];
    this.currentLevel = parent.path.length;
  } else {
    this.currentLevelElements.push(currentIndex);
  }

  const ret = this.adjacency[currentIndex].filter(l =>
    {
      return parent.path.find(p => p === l) === undefined
        && this.usedElements.find(p => p === l) === undefined;
    });

  return ret.map(r => (
    {
      word: this.list[r],
      path: [...parent.path, r],
    }
    ));
};

Test.prototype.findResults = function () {
  let current = this.queue.dequeue();
  while (current) {
    if (current) {
      if (getDifferenceNum(current.word, this.end) === 1
          && current.path.length <= this.deep) {
        this.deep = current.path.length;
        this.results.push(current.path);
      } else if (current.path.length < this.deep) {
        const children = this.findChildren(current);
        this.queue.enque(children);
      }
    }

    current = this.queue.dequeue();
  }
};

Test.prototype.filterResults = function () {
  let minLength = Number.MAX_SAFE_INTEGER;
  this.results.forEach(r => {
    if (r.length < minLength) {
      minLength = r.length;
    }
  });
  this.results = this.results.filter(r => r.length <= minLength);
};

Test.prototype.convertResults = function () {
  this.results = this.results.map(r => r.map(l => this.list[l]));
  this.results.forEach(r => r.push(this.end.join('')));
};

var findLadders = function (beginWord, endWord, wordList) {
  const tem = new Test(beginWord, endWord, wordList);
  tem.findResults();
  tem.filterResults();
  tem.list = tem.list.map(t => t.join(''));
  tem.convertResults();
  return tem.results;
};
```


[am]:https://www.google.com.au/url?sa=t&rct=j&q=&esrc=s&source=web&cd=3&ved=0ahUKEwiOpK-Fl8bQAhXMlJQKHeK9ARUQFggiMAI&url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FAdjacency_matrix&usg=AFQjCNGxQVlDVOI2_pmf2ywMgi_OSGVlCg&bvm=bv.139782543,d.dGo&cad=rja
