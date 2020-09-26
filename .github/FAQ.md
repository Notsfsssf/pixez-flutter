<img src="https://raw.githubusercontent.com/Romani-Archman/pixez-flutter/master/android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png" alt="logo" width="144" height="144" align="right">

# PixEz Flutter | 使用指南&常见问题 
如果你在使用过程中遇到了问题,请认真阅读.

## 目录
  * [声明](#声明)
  * [Pix-EzViewer的问题](#如何下载最新版)
  * [如何下载最新版](#如何下载最新版)
  * [无法登录](#登录问题)
  * [怎么全是英文???](#切换语言)
  * [下载图片](#下载图片)
  * [保存路径问题](#下载图片)
  * [保存格式](#保存格式)
  * [我是异形屏](#屏幕问题)
  * [以图搜图](#以图搜图)
  * [我想GHS](#H是不行的)
  * [其他问题](#其他问题)

## 声明
首先需要说明：这是 PixEz（Flutter 版）的 FAQ  
本教程并不是Pix-Ezviewer的教程,目前Pix-Ezviewer已经停止维护了.先由[ultranity](https://github.com/ultranity)继续维护,如果你正在使用旧的原生版本，有关任何的错误回报，你都应当联系新的维护者.

## 如何下载最新版
Pix-Ezviewer已经停止维护了,最好的做法是下载最新版的PixEz(Flutter版)  
|系统|来源|
|:---:|:---:|
|Android|[Google play](https://play.google.com/store/apps/details?id=com.perol.play.pixez) \| [GitHub Release](https://github.com/Notsfsssf/pixez-flutter/releases)|
|iOS|[App Store](https://apps.apple.com/cn/app/pixez/id1494435126)|

你也可以临时使用[蓝奏云](https://wwa.lanzous.com/b0ded45id)来下载,但是极不推荐这么做,请务必学会前往项目地址来更新

## 登录问题
如果你有账号，登录即可。  
如果你没有账号，但是又不想走繁琐的注册流程，则可以点击“没有账号？”，按流程简单操作之后 app 会为你建立一个全新的 pixiv 账号。  
注册后，请到 设置 -> 账户信息 查看你的用户名和密码，以备稍后登录。

如果你在登录过程中遇到密码错误问题,本教程不会帮你解决.  
如果你无法登录请检查网络和软件版本.

## 切换语言
如果当前界面全是英文&你不会英语,请点击右下角的settings并选择Preferences,在打开的页面中选择zh-CN并重新打开本应用便可.  
(但愿不会发生这种情况)

## 下载图片
下载按钮不外显，而是通过长按操作来实现。在主界面瀑布流长按对应插画，会自动下载该插画的所有分 p（如有）；而在插画详情界面长按插画，对于多 p 插画则可手动选择想要下载的分 p。
### 选择储存目录
从即将发布的 Android 11 开始，系统引入了新的存储机制：分区存储。为了更好地适配存储的变化，在 0.1.9 及之后的版本开始，PixEz 开始使用存储访问框架（SAF）来访问文件。
这种方式的优点是：存储操作原生化，并且不需要请求敏感的存储权限；当然，缺点也就是需要用户进行手动的目录选择。  
（了解更多详情轻点 [国内](https://developer.android.com/training/data-storage/shared/documents-files) 或 [国外](https://developer.android.com/training/data-storage/shared/documents-files)）  
一般来说，只要你的手机没有阉割系统的“文件”应用（包名为 com.android.documentsui ），你应该都能在点击“确认”之后正常来到这个应用。

如果很不幸,你的手机把他阉割了,你或许可以尝试[安装](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@master/img/DocumentsUI.apk)一个(仅限Android 9以上)  
如果被停用了,你可以尝试使用ADB来启用(具体步骤请自行百度)  

我们推荐选择的路径是 Pictures/PixEz ，当然一般来说这个路径不会从一开始就存在，所以往往文件夹需要自己来创建。

具体一点的操作方式如下：

1. 点击右上角的三个点，选择“显示内部存储空间(Show internal storage)”(如果是隐藏内部存储空间(Hide internal Storage)则无需修改)
2. 打开左侧栏，找到你的手机内部存储空间（一般为手机图标 + 手机型号，可用空间 XX GB）
3. 找到 Pictures 目录，如果你还没有 PixEz 目录则从右上角的三个点中选择“新建文件夹”
进入刚建立的 PixEz 目录，点击下面的“选择”

注意,保存路径不能包含download(下载)目录,你最好选择Pictures/PixEz路径

|![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/1.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/2.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/3.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/4.jpg) | ![Preview](https://cdn.jsdelivr.net/gh/Romani-Archman/mycdn@1.3/img/5.jpg) |
|:---:|:---:|:---:|:---:|:---:|

### 修改路径
如果后期你想修改保存路径,在设置页面中点击右上角的 <>,便可以看到修改路径选项,点击以后便可以修改.
### 动图
动图的播放按钮在详情页图片下方，点击之后便会开始获取动图内容并加载播放。动图的保存一样是长按，此时会提示是否合成动图。开始时会有 toast 提示（encoding），结束时同样有 toast 提示（encode success）。

## 保存格式
在设置页面中点击右上角的 <>,便可以看到"保存格式"选项,可以参考下面的参数来修改保存名称.
(e.p {illust_id}_p{part} 即"插画ID\_p第几张")

## 屏幕问题
如果是异形屏的话,在设置-偏好设置里勾选异形屏即可.(但愿你们不会专门来看这个问题)

## 以图搜图
目前的版本中,以图搜图在设置页面的右上角🔍中

## H是不行的
你就那么想GHS么,在 网页端（电脑或手机）登录 pixiv，找到「用户设置」-「浏览限制」，将「限制浏览的作品（R-18）」改为「显示作品」，保存设置 . 最后开启本应用设置-偏好设置中 H是可以的! (‾﹃‾)

## 其他问题
大多数选项都在设置中，建议汝仔细去找而不是什么问题都去问咱.
### 上架又下架是怎么一回事儿？
简单的来说，就是 Play 不知道发了什么神经下架了原生版之后，又在 Flutter 版上架之后将 Flutter 版下架。嘛，虽然现在历经波折，Flutter 版还是在 Play 上架了！
### 为什么有的图看不了？

一般有这些情况：

1. 原画师把图删了 / 设为隐藏了；

2. 图是 R18 的，但是你账号没开查看 R18。

例如这样：

![Preview](https://github.com/Notsfsssf/pixez-flutter/raw/master/.github/Not-Unlocked.jpg)

### 解决方法：
对于情况 1：我们表示爱莫能助… 建议利用搜索引擎的快照等尝试恢复。

对于情况 2：在 网页端（电脑或手机）登录 pixiv，找到「用户设置」-「浏览限制」，将「限制浏览的作品（R-18）」改为「显示作品」，保存设置之后在本应用内再试。

### 更多别的问题
如果你有什么好的建议,可以提issue,或者去[README.md](https://github.com/Notsfsssf/pixez-flutter)中提到的群组里反馈.如果是下载问题就去企鹅群:1005400557  
提问前最好阅读[<<提问的智慧>>](http://archman.fun/2020/09/24/%E6%8F%90%E9%97%AE%E7%9A%84%E6%99%BA%E6%85%A7/),拒绝TCP三次握手式提问,以及DDOS式轰炸提问.
