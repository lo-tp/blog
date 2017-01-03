---
title: How to Use Postmessage to Communicate with iframe in React
date: 2016-12-01 06:57:44
tags:
- React
- iframe
- postmessage
---

We all know that we should avert the use of iframe, but sometimes, we have no choice but to use it.
This article is about how to use postmessage to communicate with an iframe using React.
Assumptions were made that you know what is postmessage and how to use it, so if you are not familiar with it, read this this [introduction to postmessage][introduction] before moving on.
At first I want you to know as we need to run js on websites within and outside the child iframe so this method can only be used when you have administration privilege on both sides.

Let's see what we can do with this method.

![what we can do](/images/iframePostmessge.gif)

As you can see, informations about the scrollTop and height of the child iframe is transfered to the parent component so we can tell whether or not the child iframe is scrolled to top or bottom.

To achieve this, we had to run the following javascript inside the website which is shown inside the iframe.
```javascript
(function () {
  var scrollTop;
  var domain;
  var url;
  var body;
  var target;
  function sendHeight() {
    target.postMessage({ url: url, value: body.scrollHeight, type: 'height' }, domain);
  }

  function sendScrollTop() {
    scrollTop = body.scrollTop;
    target.postMessage({ url: url, value: scrollTop, type: 'scrollTop' }, domain);
  }

  body = document.getElementsByTagName('body')[0];
  function receiveMessage(event) {
    switch (event.data.type) {
      case 'setScroll':
        body.scrollTop = event.data.value;
        scrollTop = event.data.value;
        url = event.data.url;
        target = event.source;
        domain = event.origin;
        sendHeight();
        sendScrollTop();
        break;
    }
  }

  window.addEventListener('message', receiveMessage);
  window.addEventListener('scroll', function (e) {
    if (e.target.activeElement === body && scrollTop !== body.scrollTop) {
      sendScrollTop();
    }
  });
})();
```
Basically, the above code does 3 thing.
1. Set up a handler listening to the incoming message sent from the parent container through postmessage.
1. Set up a handler listening to the scrolling event and send scrollTop to the parent container at appropriate time.
2. Send height to the parent container;

Now let's move to the parent side.
```javascript
import React, { Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import { setScrollTop, setHeight } from './action';

class container extends Component {

  constructor(props) {
    super(props);
    this.msgHandler = this.msgHandler.bind(this);
    this.send = this.send.bind(this);
    this.componentDidMount = this.componentDidMount.bind(this);
    this.maxScrollTop = 10;
  }

  send() {
    if (this.container && this.container.contentWindow) {
      this.container.contentWindow.postMessage(this.data, '*');
      this.container.scrollTop = 20;
    }

    if (!this.received) {
      setTimeout(this.send, 100);
    }
  }

  componentDidMount() {
    this.previous = false;
    this.next = false;
    this.data = {
      url: this.props.content,
      type: 'setScroll',
      value: this.props.scrollTop,
    };
    this.send();
    this.reveived = false;
    window.addEventListener('message', this.msgHandler);
  }

  msgHandler(e) {
    if (e.data.url !== this.props.content) {
      // console.info(e.data.url);
      return;
    }

    switch (e.data.type) {
      case 'height':
        this.maxScrollTop = e.data.value - this.container.offsetHeight;
        this.received = true;
        break;
      case 'scrollTop':
        this.props.saveScroll(e.data.value);

        break;
    }
  }

  render() {
    return (
      <div
        className = 'group'
      >
        <h4 >
          {`Scroll Top:${this.props.scrollTop}`}
        </h4>
        <button
          onClick = {() => alert('wanna go to previous page?')}
          disabled={this.props.scrollTop !== 0}
        >
          Previous
        </button>
        <iframe
          ref = {e => {
            this.container = e;
          }}

          src = {this.props.content}
        />
        <button
          disabled={this.props.scrollTop < this.maxScrollTop}
            onClick = {() => alert('wanna go to next page?')}
        >
          Next
        </button>
      </div>
);
  }
}

container.propTypes = {
  scrollTop: PropTypes.number.isRequired,
  saveScroll: PropTypes.func.isRequired,
  content: PropTypes.string.isRequired,
};

container.mapStateToProps = state => ({
  scrollTop: state.scrollTop,
  height: state.height,
  content: 'http://localhost:8080/one.html',
});

container.mapDispatchToProps = dispatch => ({
  saveScroll: num => {
    dispatch(setScrollTop(Math.round(num)));
  },

  saveHeight: num => {
    dispatch(setHeight(num));
  },
});

export default connect(container.mapStateToProps,
                       container.mapDispatchToProps,
                       container.mapMergeProps)(container);
```
Firstly, `send()` is continuously invoked to establish connection with the child iframe in `componentDidMount` until a reply is recieved.
Then monitor the scrollTop and height attribute of the child iframe inside the `msgHandler`.
Having known the scrollTop and height, we can tell if the user scrolls to the top or bottom by comparing those two attributes.
### What is Missing in This Article?
For safety reasons, we should always check the origin of messages in both the parent and child sides, but to keep the article short, I ignored this part.**(Never do this in your production environment)**

If you want to know more about security measures which we should implement when using postmessage, check out this [document][introduction].
___
Full source code were disclosed at this [repo][repo], play with it if you are interested.


[repo]:https://github.com/lo-tp/exampleOfUsingPostmessageInReact
[introduction]:https://developer.mozilla.org/en-US/docs/Web/API/Window/postMessage
