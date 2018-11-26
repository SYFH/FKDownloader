# FKDonwloader 

[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![](https://img.shields.io/cocoapods/v/FKDownloader.svg?style=flat-square)](https://cocoapods.org/pods/FKDownloader)
[![](https://img.shields.io/cocoapods/p/FKDownloader.svg?style=flat-square)](https://cocoapods.org/pods/FKDownloader)
[![](https://img.shields.io/badge/language-Objective--C-orange.svg?style=flat-square)]()
[![](https://img.shields.io/cocoapods/l/FKDownloader.svg?style=flat-square)](https://github.com/SYFH/FKDownloader/blob/master/LICENSE)

👍🏻📥也许是最好的文件下载器.

# Features
* [x] 后台下载
* [x] 恢复所有后台任务和进度
* [x] 自管理任务持久化
* [x] 兼容时效性下载地址
* [x] 使用配置实例统一配置
    * [x] 可配置是否为后台下载
    * [x] 可配置是否允许蜂窝网络下载
    * [x] 可配置自动开始/自动清理
    * [x] 可配置并行任务数量
    * [x] 可配置自定义保存/缓存/恢复目录
    * [x] 可配置超时时间
    * [x] 可配置是否进行文件校验
* [x] 使用 NSProgress 管理任务进度
* [x] 所有任务总进度
* [x] 任务实时速度和预计剩余时间
* [x] 文件校验, 支持 MD5/SHA1/SHA256/SHA512, 并对特大文件校验进行了内存优化
* [x] 自定义文件名
* [x] 状态与进度数据可通过代理/通知/Block任意获取
* [x] 网络状态检测, 恢复网络时自动开始被中断的任务
* [x] 没有使用任何第三方
* [x] 兼容 Swift
* [x] 更简单的调用
* [x] 更详细的任务状态: 无/预处理/等待/进行中/完成/取消/暂停/恢复/校验/错误

# 初衷与动机
[一个系统BUG引发的血案](https://www.jianshu.com/p/72b5fe043141)

# 示例/最佳实践
请直接运行 Demo.
　　
# 安装
- CocoaPods  
　　`pod 'FKDownloader'`  
- Carthage  
　　`github 'SYFH/FKDownloader'`  
- Manual  
　　将`FKDownloader` 文件夹复制到项目中, `#import "FKDownloader.h"` 即可开始  

# 关于
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


