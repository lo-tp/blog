---
title: >-
  A Simple but Effective Learning Algorithm: MS 
  Syntax
date: 2018-08-12 08:56:00
tags: 
  - Learn
---
![Sample Image Added via Markdown](/images/2018/08/learnFast.jpg)

Personally I have been using spaced repetition algorithm in my study for many years. There are many different kinds of this algorithm and the one I have used is invented by BlueRaja called [SM2+][br] and I like it a lot. However, SM2+ has its own problem.

In this post I will show you what problems SM2+ algorithm has and provide a new algorithm named Memory Scheduler that I find quite helpful in my learning.

### Problem of SM2+
- It's a little bit complex.
- It's not compatible with the forgetting curve theory. 

### Memory Scheduler Algorithm

To learn with this algorithm, two arguments have to be fed to it:
- intervals([int]): intervals between each study session.
- scroreToProgressChange([int]): how to update the progress based on the score the user gives when reviewing items

For one item we want to learn, store two data:
- dueDate(int): the next day scheduled to review this item.
- progress(int): How many times continuously the user has correctly answered this item.

To reivew an item, the user is asked to chose a score based on how confident he is with the item(the larger, the more confident).

The answer is deemed as correct only when the score is equal to the length of scroreToProgressChange, and in this circumstance the nextDute is intervals[progress] days after today.

Otherwise, the answer is deemed as incorrect and the next review is scheduled at tomorrow.

In both cases, progress should be updated in this way: `progress+=scroreToProgressChange[score]`.

Following is a javascript implementation of this algorithm and I have also published it to npm as [memory-scheduler][ms]. If you are not satisfied with the this implementation, send me a PR at this [repo][repo].

```js
export default class MS {
  constructor(
    intervals = [1, 2, 3, 8, 17],
    scroreToProgressChange = [-3, -1, 1]
  ) {
    this.intervals = intervals;
    this.scroreToProgressChange = scroreToProgressChange;
  }

  get maxProgress() {
    return this.intervals.length;
  }
  get correctScore() {
    return this.scroreToProgressChange.length - 1;
  }
  calculate(s, { progress }, now) {
    const correct = s === this.scroreToProgressChange.length - 1;
    const newProgress = progress + this.scroreToProgressChange[s];
    let dueDate = now + 1;
    if (correct && progress < this.maxProgress) {
      dueDate = now + this.intervals[progress];
    }
    return {
      dueDate,
      progress: newProgress < 0 ? 0 : newProgress
    };
  }
  getInitialRecord(now) {
    return {
      progress: 0,
      dueDate: now
    };
  }
}
```
That's all I want to say about Memory Scheduler algorithm. As you can see, it's pretty simple to use. I believe with this algorithm, we can learn better in a faster pace.


[repo]:https://github.com/lo-tp/memory-scheduler
[br]:http://www.blueraja.com/blog/477/a-better-spaced-repetition-learning-algorithm-sm2
[ms]:https://www.npmjs.com/package/memory-scheduler
