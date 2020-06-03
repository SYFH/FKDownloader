# FKDonwloader 

[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-blue.svg?style=flat-square)](https://www.apple.com/nl/ios/)
[![Language](https://img.shields.io/badge/language-ObjC-blue.svg?style=flat-square)]()
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FKDownloader.svg?style=flat-square)](https://cocoapods.org/pods/FKDownloader)
[![](https://img.shields.io/cocoapods/l/FKDownloader.svg?style=flat-square)](https://github.com/SYFH/FKDownloader/blob/master/LICENSE)

👍🏻📥也许是最好的文件下载器.

# Features
* [x] 后台下载
* [x] 前台下载
* [x] 使用配置实例统一实行配置
* [x] 实时获取任务进度、状态等信息
* [x] 使用中间件自定义处理请求与响应
* [x] 任务可添加多个 Tag, 可通过 Tag 进行任务分组
* [x] 通过 Tag 获取组任务进度信息
* [x] 没有使用任何其他第三方

# Description
对 0.x 版本彻底重构, 移除部分冗余逻辑, 一切只为了更好的下载体验.

在使用时, 本框架并不会输出过多的信息, 比如 0.x 版本会有下载列表相关的信息, 但 1.x 并不会提供这些信息, 用户需要自己来管理这些业务相关的信息. 也不会要求输入过多的信息, 如 1.x 中整个下载流程都仅需要下载链接.

# Framework Process
![](https://pic.downk.cc/item/5e4d253e48b86553eea38f27.png)

部分逻辑参考了 Scrapy 这个广为人知的爬虫框架, 具体请看[我的博客](https://syfh.github.io/2020/02/03/%E5%AF%B9%20FKDownloader%20%E7%9A%84%E5%AE%8C%E5%85%A8%E9%87%8D%E6%9E%84/)    

# Usage
请查看 [wiki - Usage](https://github.com/SYFH/FKDownloader/wiki/Usage)    

# Requirements

| FKDownloader Versions | Minimum iOS Target |
|---|---|
| 1.x | iOS 9 |
| 0.x | iOS 8 |


# Demo
[FKDownloaderDemo](https://github.com/SYFH/FKDownloader/tree/master/FKDownloaderDemo) 为测试程序.   

# Unit Test
FKDownloader 包含了单元测试, 可在 FKDownloader.xcodeproj 中选择 FKDownloaderTest scheme 进行单元测试.    

# Install
- CocoaPods  
　　`pod 'FKDownloader'`  
- Carthage  
　　`github 'SYFH/FKDownloader'`  
- Manual  
　　将`FKDownloader` 文件夹复制到项目中, `#import "FKDownloader.h"` 即可开始    

# About
如果觉得好用, 可以 Star 哟~  
如果觉得功能不如人意, 请尽情的 Fork!  
如果使用中出现了问题, 请直接提交 issues!      

# MIT License

Copyright (c) 2018 Norld

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


