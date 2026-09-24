---
title: 'How to Customize Password Resetting Page in Meteor'
date: 2016-08-29T07:24:48
tags: [Meteor]
---
Meteor Already has a built-in password reset mechanism.
Normally, you would use it with the `accounts-ui` package.
But things become tricky when you want to customize the password resetting page.
In this article, I will walk you through on how to implement your own password resetting page in Meteor.
<!--more-->
Typically, the resetting procedure is like this:
1.	Use `Accounts.sendResetPasswordEmail` to send an email containing a link to the user.
1.	The user click the link to reset password.

The link would be similiar to this:`domainName/#/reset-password/token`.
When the user click on this link, the default page implemented with `Blaze` would appear.

To work around this, you can change the link structure with the following snippet.
```js
  Accounts.emailTemplates.resetPassword = {
    from: ()=> "xxxx@test.com",
    subject: ()=> "Reset Your Account Password",
    text: (user, url)=> {
      const newUrl = url.replace("#/reset-password", "setpswd");
      return `Hi,Click the Link below to reset your password:\n${newUrl}`;
    }
  };
```
In this way, the link sent to the user would become `domainName/setpswd/token`.
Now you can write your own version of password resetting page served on this address with whatever framework you like.
Then get the `token` from the the link address mentioned above as well as the new password and you are ready to go.
When you are done, invoke `Accounts.resetPassword(token, newPassword, [callback])` on the client side to reset the password for the user.
