---
title: temp
tags:
---

### 项目简介
------
本项目是一个背单词的APP，其核心思想是由[伍君仪]发明的[透析英语学习法]。

### 功能
------

- RSS订阅

  通过与[Inoreader]API集成，实现RSS订阅功能。

- 查词

  通过与[爱词霸]API集成，实现生词查询功能。

- 单词记忆

  通过使用[SM2]算法科学的规划单词记忆间隔，大幅度的提升单词记忆的效率，减轻背单词的负担。

- 离线阅读

  通过与[Mercury]API集成，实现网络文章全文抓取，离线缓存以及阅读功能。

- 电子书阅读

  目前仅支持Epub格式的电子书阅读，未来将加入对更多格式的支持。 

### 效果预览
------
该条目下所有内容都用GIF展现：
- 添加新文章:

  自行输入标题及网址。

- 阅读文章:
  
  直接点击已经缓存好的文章

- 阅读电子书:
  
  展示Toc,展示上篇文章下篇文章的翻页功能

- 查词:
  
  展示Fuzzing Search

- 背单词:
  
  展示下部键位的变化

- 浏览订阅

  展示订阅源，展示预览，展示加入后的效果（article list就应该多出一个条目）

### 技术介绍
------

- 前端
  
  前端采用的是React技术栈，以Redux来管理页面状态，通过React Router来设置页面路由。

- 样式
  
  没有使用任何框架，纯手写CSS，也导致界面美观度不高。

- 数据持久化
  
  包括辞典释义，网络文章的内容以及电子书阅读进度等信息都使用Localstorage缓存。

- 后端
  
  后端使用Meteor框架，数据库采用的是MongoDB。

- 跨平台支持
  
  使用Cordova封装应用。


### Todo
------

- 汉化

  汉化界面。

- Mdict离线词典

  添加对Mdict词典的支持，从而实现离线查词功能。

- 添加英英词典

  对于英语水平已经较高的用户，英英词典较中文释义的词典来说，是更好的选择。
  同时英英词典的加入，也能拓展用户群体到国际友人。

- 添加Progress Bar

  在阅读界面添加Progress Bar告诉读者阅读进度。

- IOS版本

  没有Mac呀。

### 运行项目
- 根据[Meteor Guide][mg]搭建安卓或者苹果的开发环境
- 申请[Inoreader][Inoreader],[爱词霸][爱词霸]以及[Mercury][Mercury]的开发帐号
- `git clone https://github.com/meteor/meteor.git -b release-1.4.1.3`
- `cd meteor`
- 编辑 `packages/boilerplate-generator/boilerplate_web.cordova.html"`
  修改第7行的[content security policy][csp],开启打开本地文件的权限:
  ```
  <meta http-equiv="Content-Security-Policy" content="default-src * file: cdvfile: data: blob: 'unsafe-inline' 'unsafe-eval';frame-src file: cdvfile: ;">
  ```
- `cd ../R2R`
- `../meteor/meteor npm install`
- 将测试设备和开发机器连接起来
- `ICIBA_KEY="ICIBA KEY" CLIENT_ID="Inoreader ID" CLIENT_SECRET="Inoreader Secret" MECURY_KEY="Mecury Key" ../meteor/meteor run android-device`

按此方法运行项目注册邮件以及密码重置邮件都不会发送到用户的邮箱，而是会显示在服务器的log中，注册用户以及重置密码时候请查看log中相关条目完成操作。
若想添加发送邮件的，请在运行项目时再多加一个MAIL_URL="Mail URL"的环境变量。请参阅[Meteor Email][me]以了解如何设置MAIL_URL环境变量。

### 使用
若不想自行部署，仅想试用，请下载[apk][apk]并安装，使用试用帐号登录:
- 用户名: test@qq.com
- 密码: lo7487tp

若想长期使用，请联系我：
- QQ:490628713
若想阅读电子书，请将Epub文件Copy至对应位置：
- 目录(该目录可能需要自行创建): `Android/data/com.r2r.app/books`


[apk]:http://www.baidu.com
[me]:https://docs.meteor.com/api/email.html
[mg]:https://guide.meteor.com/mobile.html
[透析英语学习法]:https://www.zhihu.com/question/23989190
[伍君仪]:http://blog.sina.com.cn/s/blog_4b5cb56b0102wf47.html
[Inoreader]:http://www.inoreader.com/
[Mercury]:https://mercury.postlight.com/
[爱词霸]:http://open.iciba.com/?c=api
[SM2]:https://github.com/lo-tp/sm2-plus
[csp]:https://content-security-policy.com/
