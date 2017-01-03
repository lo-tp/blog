---
title: Drag Gestures Inside Mobile Browsers Implemented Purely by CSS and JS
date: 2016-09-07 04:46:00
tags: 
  - UX
---
![Swipe To Delete](/images/swipteToDelete.gif)
Drag gesture, like the image above, is a very good interaction model for touch devices.
This article is about the implementation of drag gesture on mobile browsers.

I use react to simplify the code. However you can accomplish it without any framework.

The basic idea is to make a scrollable widget comprised by two component.
The first component is always visible while the second one(named **drag-btn** in this article) can only be seen after scrolling.
```js
<li
  onClick = {this.props.click.bind(this)}
  ref = {e=> {
    this.li = e;
  }}
  className = {"menu__item"}
  onScroll = {this.onScroll}
>
  <div
    className = {"text"}
  >
    <text >
      {this.props.text}
    </text>
  </div>
  <div
    ref = {e=> {
      this.dragBtn = e;
    }}
    className = {`drag-btn ${this.props.dragClass[0]}`}
  >
    <text>
      drag
    </text>
  </div>
</li>
```
We use `onscroll` to monitor the scrolling.

```js
onScroll:function() {
    this.scroll = true;
    if (this.li.scrollLeft > this.scrollThreshhold) {
      this.dragBtn.className = `drag-btn ${this.props.dragClass[1]}`;
    } else {
      this.dragBtn.className = `drag-btn ${this.props.dragClass[0]}`;
    }
  },
```
When the user scrolls to certain position, we have to tell the user that the drag action is about to be triggered.This is fulfilled by adding another class to drag-btn component to change its color.

When the user stops scrolling, a **touchend** event is emitted which can be utilized to check if drag action should be executed.
```js
onTouchEnd:function() {
  if (this.scroll) {
    if (this.li.scrollLeft > this.scrollThreshhold) {
      this.props.drag.bind(this)();
    }

    this.li.scrollLeft = 0;
    this.scroll = false;
  }
},
```
You can check the jsfiddle snippet below to see a working example.**Check it on your phone as no touchend event is emitted on the desktop browser.**

In order to keep it concise, only the most pertinent code was demonstrated in this article. 
For more details, check this [repo][repo].

{% jsfiddle nq3qero4 result,js  %}

[repo]:https://github.com/lo-tp/DragInBrowsers
