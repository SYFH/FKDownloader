# FKDonwloader 

[![Support](https://img.shields.io/badge/support-iOS%208%2B%20-blue.svg?style=flat-square)](https://www.apple.com/nl/ios/)
[![Language](https://img.shields.io/badge/language-ObjC%7CSwift-blue.svg?style=flat-square)]()
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FKDownloader.svg?style=flat-square)](https://cocoapods.org/pods/FKDownloader)
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

# 简单使用 -- ObjC
- 任务管理

``` Objective-C
// 添加任务, 但不执行, 适合批量添加任务的场景
[[FKDownloadManager manager] add:@"URL"];

// 添加任务, 并附加额外信息, 目前支持 URL, 自定义保存文件名, 校验值, 校验类型, 自定义请求头
[[FKDownloadManager manager] addInfo:@{FKTaskInfoURL: @"URL",
                                       FKTaskInfoFileName: @"xCode7",
                                       FKTaskInfoVerificationType: @(VerifyTypeMD5),
                                       FKTaskInfoVerification: @"5f75fe52c15566a12b012db21808ad8c",
                                       FKTaskInfoRequestHeader: @{} }];

// 开始执行任务
[[FKDownloadManager manager] start:@"URL"];

// 根据 URL 获取任务
[[FKDownloadManager manager] acquire:@"URL"];

// 暂停任务
[[FKDownloadManager manager] suspend:@"URL"];

// 恢复任务
[[FKDownloadManager manager] resume:@"URL"];

// 取消任务
[[FKDownloadManager manager] cancel:@"URL"];

// 移除任务
[[FKDownloadManager manager] remove:@"URL"];

// 设置任务代理
[[FKDownloadManager manager] acquire:@"URL"].delegate = self;

// 设置任务 Block
[[FKDownloadManager manager] acquire:@"URL"].statusBlock = ^(FKTask *task) {
    // 状态改变时被调用
};
[[FKDownloadManager manager] acquire:@"URL"].speedBlock = ^(FKTask *task) {
    // 下载速度, 默认 1s 调用一次
};
[[FKDownloadManager manager] acquire:@"URL"].progressBlock = ^(FKTask *task) {
    // 进度改变时被调用
};

```

- 支持的任务通知

```
// 与代理同价, 可按照代理的使用方式使用通知.
extern FKNotificationName const FKTaskPrepareNotification;
extern FKNotificationName const FKTaskDidIdleNotification;
extern FKNotificationName const FKTaskWillExecuteNotification;
extern FKNotificationName const FKTaskDidExecuteNotication;
extern FKNotificationName const FKTaskProgressNotication;
extern FKNotificationName const FKTaskDidResumingNotification;
extern FKNotificationName const FKTaskWillChecksumNotification;
extern FKNotificationName const FKTaskDidChecksumNotification;
extern FKNotificationName const FKTaskDidFinishNotication;
extern FKNotificationName const FKTaskErrorNotication;
extern FKNotificationName const FKTaskWillSuspendNotication;
extern FKNotificationName const FKTaskDidSuspendNotication;
extern FKNotificationName const FKTaskWillCancelldNotication;
extern FKNotificationName const FKTaskDidCancelldNotication;
extern FKNotificationName const FKTaskSpeedInfoNotication;
```

- 需要在 AppDelegate 中调用的

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化统一配置, 最好在 App 最开始配置好, 如果不进行设置将直接使用默认配置
    FKConfigure *config = [FKConfigure defaultConfigure];
    config.isBackgroudExecute = YES;
    config.isAutoClearTask = NO;
    config.isAutoStart = NO;
    config.isFileChecksum = YES;
    config.speedRefreshInterval = 1;
    [FKDownloadManager manager].configure = config;
    
    // 恢复持久化的任务与状态, 并获取正在进行的后台任务的进度
    [[FKDownloadManager manager] restory];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 修复特定设备与版本出现的进度无法改变的 BUG
    [[FKDownloadManager manager] fixProgressNotChanage];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    
    // 保存后台下载所需的系统 Block, 区别 identifier 以防止与其他第三方冲突
    if ([identifier isEqualToString:[FKDownloadManager manager].configure.sessionIdentifier]) {
        [FKDownloadManager manager].configure.backgroundHandler = completionHandler;
    }
}
```

# 简单使用 -- Swift
- 任务管理

``` Swift
// 添加任务, 但不执行, 适合批量添加任务的场景
Downloader.shared().add("URL")

// 添加任务, 并附加额外信息, 目前支持 URL, 自定义保存文件名, 校验值, 校验类型, 自定义请求头
Downloader.shared().addInfo([FKTaskInfoURL: "URL",
                             FKTaskInfoFileName: "xCode9",
                             FKTaskInfoVerification: "5f75fe52c15566a12b012db21808ad8c",
                             FKTaskInfoVerificationType: VerifyType.MD5,
                             FKTaskInfoRequestHeader: []])

// 开始执行任务
Downloader.shared().start("URL")

// 根据 URL 获取任务
Downloader.shared().acquire("URL")

// 暂停任务
Downloader.shared().suspend("URL")

// 恢复任务
Downloader.shared().resume("URL")

// 取消任务
Downloader.shared().cancel("URL")

// 移除任务
Downloader.shared().remove("URL")

// 设置任务代理
Downloader.shared().acquire("URL")?.delegate = self

// 设置任务 Block
Downloader.shared().acquire("URL")?.statusBlock = { (task) in
    // 状态改变时被调用
}
Downloader.shared().acquire("URL")?.progressBlock = { (task) in
    // 下载速度, 默认 1s 调用一次
}
Downloader.shared().acquire("URL")?.speedBlock = { (task) in
    // 进度改变时被调用
}

```

- 支持的任务通知

``` Swift
// 与代理同价, 可按照代理的使用方式使用通知.
extension NSNotification.Name {

    public static let FKTaskPrepare: NSNotification.Name

    public static let FKTaskDidIdle: NSNotification.Name

    public static let FKTaskWillExecute: NSNotification.Name

    public static let FKTaskDidExecute: NSNotification.Name

    public static let FKTaskProgress: NSNotification.Name

    public static let FKTaskDidResuming: NSNotification.Name

    public static let FKTaskWillChecksum: NSNotification.Name

    public static let FKTaskDidChecksum: NSNotification.Name

    public static let FKTaskDidFinish: NSNotification.Name

    public static let FKTaskError: NSNotification.Name

    public static let FKTaskWillSuspend: NSNotification.Name

    public static let FKTaskDidSuspend: NSNotification.Name

    public static let FKTaskWillCancelld: NSNotification.Name

    public static let FKTaskDidCancelld: NSNotification.Name

    public static let FKTaskSpeedInfo: NSNotification.Name
}
```

- 需要在 AppDelegate 中调用的

``` Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
    let config = Configure.default()
    config.isBackgroudExecute = true
    config.isAutoClearTask = false
    config.isAutoStart = false
    config.isFileChecksum = true
    config.speedRefreshInterval = 1
    Downloader.shared().configure = config
        
    Downloader.shared().restory()
        
    return true
}

func applicationDidBecomeActive(_ application: UIApplication) {
    Downloader.shared().fixProgressNotChanage()
}
    
func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        
    if identifier == Downloader.shared().configure.sessionIdentifier {
        Downloader.shared().configure.backgroundHandler = completionHandler
    }
}
```

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


