# FKDonwloader
简单易用的多文件下载器

# Features
* [x] 后台下载
* [x] 恢复所有后台任务和进度
* [x] 自管理任务持久化
* [x] 实用配置实例统一配置
    * [x] 可配置是否为后台下载
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
* [x] 没有使用任何第三方
* [x] 更简单的调用
* [x] 更详细的任务状态: 无/预处理/等待/进行中/完成/取消/暂停/恢复/校验/错误

# TODO
* [ ] 兼容 Swift

# 针对 iOS 系统 BUG 方案
- 后台任务无效

　　在 iOS 12/12.1, iPhone 8 以下的机型中会出现, 退出应用后, 后台任务会被取消, 但带有恢复数据.  
　　解决思路: 将带有恢复数据的已取消任务手动开始.  
　　解决方法: 在 `-[AppDelegate didFinishLaunchingWithOptions:]` 中进行 `FKDownloadManager` 自定义配置后, 调用 `-[FKDownloadManager restory]` 即可.  

- 进入后台, 再进入前台后, 任务不能获取进度

　　在 iOS 12/12.1, iPhone 8 以下的机型中会出现进入后台一段时间后, 所有后台任务会获取不到进度, 但下载仍在继续, 而 `NSURLSessionDownloadDelegate` 的进度回调没有被调用, `KVO` 监听 `NSURLSessionDownloadTask` 的 `countOfBytesReceived` 属性也没有变动, 初步认为是系统 BUG, 已接收字节在回到前台后就不再变动, 只在暂停/取消时会变动几次.  
　　解决思路: 手动暂停再继续, 简单直接, 但要注意: 暂停无效, 需要使用带有恢复数据的取消方法, 并且该方法在 `-[AppDelegate applicationWillEnterForeground:]` 中无效.  
　　解决方法: 在 `-[AppDelegate applicationDidBecomeActive:]` 方法中调用 `+[FKDownloadManager fixProgressNotChanage]` 即可.  


# 示例
　　直接运行 Demo 即可.
　　
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


