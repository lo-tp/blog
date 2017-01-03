---
title: How-to-Write-Your-Redux-Action-in-a-More-Concise-Style
date: 2016-11-06 06:26:22
tags: 
- Redux 
- Functional Programming
---

Let's say you are working on a project about article writing and now you are about to write actions to create and update articles.
To create an article, you would need an action creator like this.
```js
export const createArticle = title => {
    return {
        type: ARTICLE,
        operation: CREATE,
        title
    }
}
```

When it comes to article updating, you need another action creator.
```js
export const updateArticle = ( newTitle, title) => {
    return {
        type: ARTICLE,
        operation: UPDATE,
        title,
        newTitle
    }
}
```

These two functions looks like each other very much.
Tasks like these are tedious and you may wonder if there is a way to get rid of these repetitive jobs.

Of course yes, but you need some extra help.
I highly recommend you to read the wiki page of [functional programming][fp] if it's new to you.
Otherwise the following snippets may be very strange to you.

To do functional programming, you may need some help of libraries such as [Ramda][rd].

```js
const R = require("ramda");
const actionArg = R.curry((type, operation, newTitle, title)=> (
  {
    type, operation, title, newTitle
  }
));
export const actionOfArticle = actionArg(ARTICLE);
```

With the above snippet, basically you are defining a function called `actionArg` that would return another function.
The function returned by `actionArg` would return an object describing the action you are creating.
At the last line you are making an action to deal with all the article related stuff.

Here comes the magic.
Now, to create an article, you just need to define an one line function.
```js
export const createArticle = actionOfArticle(CREATE,0,R.__)
```
Also it becomes easier if you want to update the title of an existing article.
```js
export const updateArticle = actionOfArticle(UPDATE,R.__,R.__)
```
This may not seem to be useful when you are only dealing with simple actions.
However when actions become complex, you can save a lot of time by writing actions in this way.

[fp]:https://en.wikipedia.org/wiki/Functional_programming
[rd]:http://ramdajs.com/
