# FKDonwloader 

[![Support](https://img.shields.io/badge/support-iOS%209%2B%20-blue.svg?style=flat-square)](https://www.apple.com/nl/ios/)
[![Language](https://img.shields.io/badge/language-ObjC-blue.svg?style=flat-square)]()
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FKDownloader.svg?style=flat-square)](https://cocoapods.org/pods/FKDownloader)
[![](https://img.shields.io/cocoapods/l/FKDownloader.svg?style=flat-square)](https://github.com/SYFH/FKDownloader/blob/master/LICENSE)

👍🏻📥也许是最好的文件下载器.

# Features
* [x] 后台下载
* [x] 使用配置实例统一配置
* [x] 实时获取任务进度、状态等信息
* [x] 使用中间件自定义处理请求与响应
* [x] 任务可添加多个 Tag, 并通过 Tag 进行分组
* [x] 通过 Tag 获取组任务进度
* [x] 没有使用任何第三方

# Description
对 0.x 版本彻底重构, 移除部分冗余逻辑, 一切只为了更好的下载体验.

# Framework Process
![](https://pic.downk.cc/item/5e2556dc2fb38b8c3c996a09.jpg)

部分逻辑参考了 Scrapy 这个广为人知的爬虫框架    

# Usage
在使用 FKDownloader 时主要是对 5 个类进行操作.

### FKConfigure

配置类, 负责配置下载中所需要的参数, 最好在应用启动后立即配置.    

配置最大下载数量, 默认 3, 设定范围 1 ~ 6    
```
[FKConfigure configure].maxAction = 3;
```    

配置 NSURLSessionConfiguration, 鉴于系统类中包含了新的特性, 所以配置相关都在一个模版上进行配置, FKDownloader 会以此模版进行配置 Session, 其中 `allowsCellularAccess` 为默认开启    
```
[FKConfigure configure].templateBackgroundConfiguration.allowsCellularAccess = NO;
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
```
[FKControl resumeRequestWithURL:@"Download URL"];
```    

取消任务, 对 FKStateAction 和 FKStateSuspend 状态生效    
```
[FKControl cancelRequestWithURL:@"Download URL"];
```    

取消所有请求, 会对 Background Session 所有的, 状态为 NSURLSessionTaskStateRunning 的 Download Task 进行取消操作
```
[FKControl cancelAllRequest];
```    

删除任务所有文件, 可视作彻底移出任务, 但最好在任务已完成, 已取消的状态下执行, 其他状态可能会出现意外情况.      
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

### FKMessager
负责获取任务对应的信息    

获取下载链接对应任务信息, 注意, 回调不在主线程, 如需 UI 操作请自行切换线程    
```
[FKMessager messagerWithURL:@"Download URL" info:^(int64_t countOfBytesReceived,
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

获取一个集合的任务信息, 基本上, 集合信息只是最基本的数据, 只有总大小和已下载大小, 状态之类的数据请自行记录和控制    
```    
[FKMessager messagerWithBarrel:@"name" info:^(int64_t countOfBytesReceived, int64_t countOfBytesExpectedToReceive) {
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


