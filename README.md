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
在使用 FKDownloader 时主要是对 5 个类进行操作.

### FKConfigure

配置类, 负责配置下载中所需要的参数, 最好在应用启动后立即配置.    

配置最大下载数量, 默认 3, 设定范围 1 ~ 6    
```
[FKConfigure configure].maxAction = 3;
```   

配置信息分发速率, 默认 5 倍, 最小 1 倍, 最大 10 倍, 1 倍为 0.2 秒    
```
[FKConfigure configure].distributeSpeed = 5;
```    

配置 NSURLSessionConfiguration, 包含 `Background Session` 和 `Foreground Session`. 鉴于系统类中包含了新的特性, 所以配置相关都在一个模版上进行配置, FKDownloader 会以此模版进行配置 Session, 其中 `allowsCellularAccess` 为默认开启    
```
[FKConfigure configure].templateBackgroundConfiguration.allowsCellularAccess = NO;
[FKConfigure configure].templateForegroundConfiguration.allowsCellularAccess = NO;
```    

配置后台下载的系统回调, 此方法在 `-[AppDelegate application:handleEventsForBackgroundURLSession:completionHandler]` 中使用    
```
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    if ([identifier isEqualToString:[FKConfigure configure].backgroundSessionIdentifier]) {
        [FKConfigure configure].completionHandler = completionHandler;
    }
}
```    

配置完成后, 使配置生效    
```
[[FKConfigure configure] takeSession];
```    

FKDownloader 采用计时器执行轮询执行任务, 间隔 1s, 默认情况下, 该计时器不会激活, 需要现式激活后才可进行任务    
```
[[FKConfigure configure] activateQueue];
```     

### FKBuilder    

构建者主要负责创建任务, 设定任务的基本信息等.    
    
使用链接进行构建    
```
FKBuilder *builder = [FKBuilder buildWithURL:@"Download URL"];
```    

配置下载类型, 支持前台下载和后台下载, 默认为后台下载    
```
builder.downloadType = FKDownloadBackground;
```     

对下载链接进行预处理, 这一步主要流程为:    
1. 创建下载任务对应的文件夹与信息描述文件    
2. 生成内部使用的唯一任务编号    
3. 将任务放入内部缓存    

```
[builder prepare];
```    

FKDownloader 的每一个任务都对应一个本地信息文件, 当 App 因为重启等原因丢失内存缓存时, 一些信息获取逻辑会在控制台提示任务不存在等信息, 这时就需要手动执行上述流程, 使任务信息加载到内存中. 该场景可在 Demo 中下载信息列表界面中, 每个 Cell 赋值 URL 时看到.

### FKControl
主要负责控制任务状态    

激活任务, 对 FKStateCancel 和 FKStateError 状态生效, 将任务重新排到任务队列中    
```
[FKControl actionRequestWithURL:@"Download URL"];
```    

暂停任务, 对 FKStateAction 状态生效    
```
[FKControl suspendRequestWithURL:@"Download URL"];
```    

继续任务, 对 FKStateSuspend 状态生效    
对于前台任务, 重启 App 后, 状态会重置为暂停, 执行继续将重新下载    
```
[FKControl resumeRequestWithURL:@"Download URL"];
```    

取消任务, 对 FKStateAction, FKStateSuspend, FKStateIdel 和 FKStateError 状态生效    
```
[FKControl cancelRequestWithURL:@"Download URL"];
```    

取消所有请求, 会对 Background Session 所有的, 状态为 NSURLSessionTaskStateRunning 的 Download Task 进行取消操作
```
[FKControl cancelAllRequest];
```    

删除任务所有文件, 可视作彻底移除任务, 但最好在任务已完成, 或已取消的状态下执行, 其他状态可能会出现意外情况.      
```
[FKControl trashRequestWithURL:@"Download URL"];
```    

直接获取下载链接对应任务的状态    
```
FKState state = [FKControl stateWithURL:@"Download URL"];
```    

直接获取下载链接对应任务的错误信息, 可能为空值    
```
NSError *error = [FKControl errorWithURL:@"Download URL"];
```    

直接获取下载链接对应文件的路径, 文件可能不存在
```
NSString *path = [FKControl downloadedFilePathWithURL:@"Download URL"];
```     

### FKMessager
负责获取任务对应的信息    

获取下载链接对应任务信息, 注意, 回调不在主线程, 如需 UI 操作请自行切换线程    
```
[FKMessager messagerWithURL:@"Download URL" info:^(int64_t countOfBytesReceived,
                                                   int64_t countOfBytesPreviousReceived,
                                                   int64_t countOfBytesExpectedToReceive,
                                                   FKState state,
                                                   NSError * _Nullable error) {
        
    // do something...
}];
```    

将多个链接标记为一个任务集合    
```
// Add
[FKMessager addMessagerWithURLs:@[@"Download URL"] barrel:@"name"];

// Delete
[FKMessager removeMessagerBarrel:@"name"];
```    

获取一个集合的任务信息, 基本上, 集合信息只是最基本的数据, 只有总大小, 上次已下载大小和已下载大小, 状态之类的数据请自行记录和控制    
```    
[FKMessager messagerWithBarrel:@"name" info:^(int64_t countOfBytesReceived, int64_t countOfBytesPreviousReceived, int64_t countOfBytesExpectedToReceive) {
    // do something...
}];
```    

### FKMiddleware
管理中间件, 主要包括请求中间件与响应中间件    

注册请求中间件, 在构建 NSMutableURLRequest 时, 会依次调用中间件来处理请求, FKDownloader 会使用最终的 NSMutableURLRequest 来进行下载    
```
[[FKMiddleware shared] registeRequestMiddleware:[CustomRequestMiddleware new]];
```    

这册响应中间件, 在任务完成下载或出错中断后被调用, 可以用来处理文件校验, 移动文件到指定路径等操作.    
```
[[FKMiddleware shared] registeResponseMiddleware:[CustomResponseMiddleware new]];
```    

请求中间件类需要遵循 `FKRequestMiddlewareProtocol` 协议, 并实现被标记为 `@required` 的方法与属性, 其中 `priority` 表示优先级, 类型为正整数, 值越接近 0, 优先级越高, 响应中间件协议 `FKResponseMiddlewareProtocol` 的 `priority` 属性与请求中间件逻辑一致.    

请求中间件协议中 `processRequest:` 方法会传进来一个 NSMutableURLRequest 对象, 请在进行自定义处理后直接返回一个 NSMutableURLRequest 对象.    

响应中间件协议中 `processResponse:` 方法会传进来一个 FKResponse 对象, 对象结构如下:    
```
@interface FKResponse : NSObject

@property (nonatomic, strong) NSString *originalURL;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong, nullable) NSError *error;

@end
```    

其中 originalURL 是在构建时传入的链接, response 为系统返回的请求响应信息, 可从中获取相应头的信息. filePath 为下载的文件路径, 下载请求完成后, 文件会移动到此路径, 注意, 文件可能不存在. error 为系统返回的请求响应错误, 可能为网络中断, 验证无法通过, 不合法的返回值等问题.    

# Requirements

| FKDownloader Versions | Minimum iOS Target |
|---|---|
| 1.x | iOS 9 |
| 0.x | iOS 8 |


# Demo
FKDownloaderDemo 文件夹内为测试程序.   

# Unit Test
FKDownloader 包含了单元测试, 可在 FKDownloader.xcodeproj 中选择 FKDownloaderTest scheme 进行单元测试.    

# Install
- CocoaPods  
　　`pod 'FKDownloader'`  
- Carthage  
　　`github 'SYFH/FKDownloader'`  
- Manual  
　　将`FKDownloader` 文件夹复制到项目中, `#import "FKDownloader.h"` 即可开始  

# Change log
- 1.0.9
    1. 优化便捷类内部逻辑
    2. FKConfigure 添加工作目录属性
- 1.0.8
    1. 优化下载中间件调用逻辑
    2. 下载中间件状态获取添加错误信息参数
- 1.0.7
    1. 添加下载中间件, 可获取下载进度和下载状态, 与 FKMessager 不同, 不会循环调用, 下载进度与 NSURLSessionDownloadTask 的进度同步, 下载状态只在状态被改变时调用
- 1.0.6
    1. 添加便捷类 FKDownloader, 可直接进行简单操作
    2. FKBuilder 修改初始化逻辑, URL 不合法时返回 nil
    3. FKControl 添加开始/暂停/恢复所有任务 API
    4. 修复上次已下载大小逻辑
- 1.0.5
    1. FKMessger 添加检查任务是否存在 API
    2. 添加任务状态 FKStateUnknown, 表示任务不存在
- 1.0.4
    1. 对 FKMessager 添加删除回调缓存 API, 单次获取任务信息 API, 对集合增删改查链接信息 API
    2. 调整 FKControl API
    3. FKBuilder 添加从缓存加载任务 API, 减少预处理操作面
    4. 修改系统下载回调逻辑
    5. 补充单元测试
- 1.0.3
    1. 支持前台下载
    2. 优化下载完成流程, 响应中间件只在请求完成, 数据接收错误时执行
    3. 修改下载暂停操作, 防止使用恢复操作绕过最大执行数限制
    4. 修复删除任务不完全的问题
    5. Demo 支持删除任务操作
    6. 修复消息分发队列代码错误
- 1.0.2
    1. 取消操作增加允许的状态
    2. 将信息分发计时器独立, 并支持自定义速率配置
    3. 分发信息添加上次已下载数据长度, 可进行速度计算
    4. 修复一些问题
- 1.0.1     
    1. 针对特定版本修正恢复数据
    2. 针对特定版本修复前后台切换导致的下载进度监听无效的问题
    3. 优化 FKObserver, 将缓存移入 FKCache 中
    4. Demo 添加强制退出选项
- 1.0.0    
    对 0.x 彻底重构, 完成框架完整逻辑, 机型/系统 BUG 等需要继续完善    

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


