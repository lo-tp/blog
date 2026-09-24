---
title: 'My First Try at TDD: How I Test Asynchronous Code in Mocha With async/await Syntax'
date: 2017-01-05T13:56:47
tags: [Test, TDD, Mocha, ES7]
---

Every body knows that writing unit test is very important during programming.
However, it is not an easy job, especially when it comes to `asynchronous code`.

Initially, callback has to be used to test `asynchronous code`:
```javascript
describe('User Profile', function(){
  it('can get user profile', function(done){
    getProfile('bulkan', function(err, result){
      if(err) {
        done(err)
      }
      assert.equal(result.userName, 'bulkan');
      done();
    });
  });
});
```
This kind of test could easily turned out to be a [callback hell][ch] when the logic become complex.
Thank god, with the advent of `promise`, testing `asynchronous code` is not that much depressing now.

```javascript
describe('User Profile', function(){
  it('can get user profile', function(done){
    getProfile('bulkan')
    .then(function(result){
      assert.equal(result.userName, 'bulkan');
      done();
    })
    .catch(function(err){
      done(err);
    });
  });
});
```
Actually manually calling `done` is not necessary any more in newer version of mocha, as mocha takes care of promise itself pretty well.
So the above code can be written as:
```javascript
describe('User Profile', function(){
  it('can get user profile', function(){
    return getProfile('bulkan')
    .then(function(result){
      assert.equal(result.userName, 'bulkan');
    })
  });
});
```
Now this looks good. 
However, we won't be satisfied with this, will we?
Take a look at how this code could be further improved with `async/await`.
```javascript
describe('User Profile', function(){
  it('can get user profile', async function(){
    const result = await getProfile('bulkan');
    assert.equal(result.userName, 'bulkan');
  });
});
```
In the above snippet, we are taking advantage of of one lovely feature of Async functions:
> Async functions always return a promise, no matter whether or not await is invoked.
> The promise, returned by async function, would resolve with whatever the async function returns, or rejects with whatever the async function throws.
With the `async/await`, testing asynchronous code is nearly identical to testing synchronous code.
Cheer!!!
___
##### Caveat
Every thing comes at a price.
Although it is very trendy now, we still need a transpiler like `bable` to use `async/await`.
What a pity.
[ch]:http://callbackhell.com/
