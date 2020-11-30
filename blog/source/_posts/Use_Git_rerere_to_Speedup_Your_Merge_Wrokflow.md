---
title: >-
  Speed Up Your Git Merge Flow With 'git rerere'
date: 2020-11-30 14:29:00
tags: 
  - Git
---

TLDR: Tired of manual conflict resolution? Run `git config rerere.enabled true` to enable the **rerere** feature which will remember conflict resolutions so you don't have to resolve the same conflict over and over agin.

---

Recently I came across a case of parallel development on two different repos originating from one common code base.
Things went well until conflicts started to arise like the follwing picture.
![Initial State](/images/2020/rerere/1.png)
Initially conflicts were resolved manually. 
![Manually Reslotion](/images/2020/rerere/2.png)
As time passing by, conflicts started to show up in the same file repetitively and I got bored in resolving the same conflict over and over again.
I started to ask myself can I find a better way to eliminate these redundant work.
![Initial State](/images/2020/rerere/3.png)
After some research, I found **git rerere**.
Basically it's a feature built in git which will record the conflict merge results after being turned on so that no human intervention will be required to merge the code when the same conflict emerges again.
To use it, all you have to do is just run `git config rerere.enabled true` to turn it on. After that, all manually code merge would be recorded and reused later when meeting with same conflicts.
