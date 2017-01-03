---
title: Interview Quiz
---
#### [Responsive Web Design]
- What It Is?
Responsive web design, originally defined by Ethan Marcotte in A List Apart, responds to the needs of the users and the devices they're using. The layout changes based on the size and capabilities of the device. For example, on a phone users would see content shown in a single column view; a tablet might show the same content in two columns.
- How to Make a Responsive Design
  - `<meta name="viewport" content="width=device-width, initial-scale=1">`(What do these two attribute do?
  - Use relative units in lieu of absolute ones.
  - Use `media query` to enable layout to adjust it self to different devices.(width, height, orientation)

#### [Differentiate Between AMD and CommonJs](zccst.iteye.com/blog/2215317)

#### [Differentiate Between undeclared, undefined, null](http://lucybain.com/blog/2014/null-undefined-undeclared/)

#### [What Is a IIFE](http://gregfranko.com/blog/i-love-my-iife/)
  - why the following doesn't work as an IIFE: `function foo(){ }();`
  - What needs to be changed to properly make it an IIFE.

#### Semantic Html
- What It Is?
Semantic HTML is the use of HTML markup to reinforce the semantics, or meaning, of the information in webpages and web applications rather than merely to define its presentation or look.
- Why Html5 is Special Very Important When Talking about This Problem?
  `class=footer class=nav` => `<footer> <nav>`

#### [React Virtual Dom]
- What is Dom?
Just to get things straight - DOM stands for Document Object Model and is an abstraction of a structured text. For web developers, this text is an HTML code, and the DOM is simply called HTML DOM. Elements of HTML become nodes in the DOM.

- Why We Need Virtual Dom?
Virutal dom is flexible, the cost of updating virtual dom is much more lower than that of changing the real dom.
When changes happen, react could compare the virtual dom to see which part of the real dom needs to be updated, and update them all at once.
Doing multiple updates at one time is much better then do consequtive single changes.

#### [Explain event delegation](https://learn.jquery.com/events/event-delegation/)
Event delegation refers to the process of using event propagation (bubbling) to handle events at a higher level in the DOM than the element on which the event originated. It allows us to attach a single event listener for elements that exist now or in the future.

#### [This in Js](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Operators/this)
- Global Context
- Function Context
- Arrow Functions
- Object Methods
- Constructor
- Event Handler

#### [Inheritance and the prototype chain](https://developer.mozilla.org/en/docs/Web/JavaScript/Inheritance_and_the_prototype_chain)
- What is Prototype Chain?
- Different ways to create objects and the resulting prototype chain:
    - Syntax constructors:`var o = {a: 1};`
    - Constructor: `var g = new Graph();`
    - Object.create:`var b = Object.create(a);`
    - With the class keyword:
        ```
        class Polygon {
          constructor(height, width) {
            this.height = height;
            this.width = width;
          }
        }
        ```
#### [KMP String Pattern Matching](http://jakeboxer.com/blog/2009/12/13/the-knuth-morris-pratt-algorithm-in-my-own-words/)
[Visualizing String Matching](http://whocouldthat.be/visualizing-string-matching/)
- The Theory Behind KMP?
- How to Calculate Partial Match Table?
- How to Use Partial Partial Match Table?

#### [Network Related](https://www.youtube.com/watch?v=e5DEVa9eSN0&ab_channel=blanchae)
- The TCP/IP layer and OSI Model.
- The PDU, address and protocol of each layer?
- What is the use of dns procotol?
- What is the use of arp procotol?
- What is the use of NAT and NAPT protocol?
- [How to categorize IP address](http://www.tcpipguide.com/free/t_IPAddressClassABandCNetworkandHostCapacities.htm)?
- [What is the use of subnet mask](https://technet.microsoft.com/en-us/library/cc958832.aspx)?
- What does 24 mean in 138.96.58.0/24?
- [Describe the connection establishing process in TCP protocol(sequence number)](http://packetlife.net/blog/2010/jun/7/understanding-tcp-sequence-acknowledgment-numbers/).
- [Describe the connection closing process in TCP protocol](http://www.tcpipguide.com/free/t_TCPConnectionTermination-2.htm).
- [What happens when we visit a website in our browser](http://xunyunyun.github.io/http/http-interview-questions.html)
- [Diffentiate between get and post](http://blog.csdn.net/zhangliangzi/article/details/51336564)
- [Explain HTTPS](https://en.wikipedia.org/wiki/Transport_Layer_Security)

#### [Front End Performance Optimizatio](https://jonsuh.com/blog/need-for-speed-2/#css)
- Reduce requests
- Compress and merge external files.
- Compress binary datas.
- Partial rendering(using inline critical css and `defer` to load js)

#### [Why React Is Special]
- JSX makes writing js easier.
- Resuable component 
- Virtual dom

#### [Websites You Vist to Learn New Tech]
- [hacker news](http://hackernews.com/)
- [smashing magzine](https://www.smashingmagazine.com/)
- [css tricks](https://css-tricks.com/)
- [david walsh blog](https://davidwalsh.name/)

[Responsive Web Design]:https://developers.google.com/web/fundamentals/design-and-ui/responsive/
[React Virtual Dom]:https://www.accelebrate.com/blog/the-real-benefits-of-the-virtual-dom-in-react-js/
