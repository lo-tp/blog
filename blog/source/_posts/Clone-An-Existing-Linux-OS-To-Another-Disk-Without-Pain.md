---
title: A Painless Way to Clone an Existing Linux OS to Another Disk
date: 2016-08-29 09:08:11
tags: Linux
---
We all know that installing operation system is a toil.
**So let's say no to restinalling OS.**
Recently, I bought a larger SSD and intended to use it to replace the older one.
In order to circumvent all the dull jobs I have to do with the reinstalling thing, I decided to clone the existing Ubuntu Mate 14.04 from my older SSD to the newly bought one.
Luckily I succeeded.
<!-- more -->

### Cautions
Make sure the size of the destination disk is equal to or larger than the that of the original one.

### Using `dd` To Clone the Disk
Plug in the new disk to your computer and check the corressponding dev files of the disks.
In my case, the old disk is */dev/sda* and the new disk is */dev/sdb*.
Run the following command to fully transfer the content(**Please pay extra attention when using dd**).
`dd if=/dev/sda of=/dev/sdb`.

### Change UUID
Using `dd`, the UUID of partitions on the two disks will be the same.
This may lead to some conflict, so we have to change the UUID of the partitions on the new disk.
In my case, I got two new partitions: sdb1 and sdb2.
And I changed UUID using this command:
``tune2fs /dev/sdbX -U `uuidgen` ``.
Now shutdown your PC, install the new disk to the port of the older one and restart your PC to enjoy your new system.

### Extend the Partition and File System of the New Disk
With `dd`, you get an exact copy of your older disk. 
That is to say, the space of the partition on the new disk is also the same as the older one.
You know in most circumstances, we would buy a larger disk to replace the older one.
So if we leave it as it is now, there would be a waste disk space.

Fortunately, we could work around this problem.
Boot your PC from the older disk with the new one also on your machine.
1.	Use `fdisk` to remove the partitions on the new disk.
1.	Use `fdisk` to recreate the partition with the desirable size(Be careful here to make sure that the **First sector** is the same as that of the removed partition).
1.	Use `fsck` to check everything you've done to your partition is ok.
1.	Use `resize2fs` to resize the file system.

If you need furture help about how to extend, check [this post][resize].

[resize]:https://geekpeek.net/resize-filesystem-fdisk-resize2fs/

### Repair Grub
If your plan is to use the new disk in a port different to the original one, then there will be some more work to do.

As I've mention before, `dd` copys every thing from the original disk to the new one exactly. 
Of no exception is the boot files

To solve this problem, you'll have to repair your boot files.
Luckily, we can accomplish this mission with the benefit of a software called *boot-repair* made by some kind people(Cheers).
All you have to do is to download the [image][bootRepair] of *boot-repair* and burn the image to a usb stick to make a bootable usb disk.
Boot your computer from the newly created usb disk and a wizard like this would appear.

![wizard][wizard]
[bootRepair]:http://sourceforge.net/projects/boot-repair-cd/
[wizard]:http://ww4.sinaimg.cn/mw690/005N6Qx8gw1eyovjprve4j31050kqgth.jpg

Choose recommended repair and wait for a while.
After a quick reboot, your computer would be ready to use with the new disk properly configured.
