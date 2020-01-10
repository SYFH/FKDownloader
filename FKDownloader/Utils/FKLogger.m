//
//  FKLogger.m
//  FKDownloader
//
//  Created by norld on 2020/1/8.
//  Copyright © 2020 norld. All rights reserved.
//

#import "FKLogger.h"

@implementation FKLogger

+ (void)info:(NSString *)info, ... NS_FORMAT_FUNCTION(1,2) {
#if DEBUG
    va_list args;
    
    va_start(args, info);
    NSString *str = [[NSString alloc] initWithFormat:info arguments:args];
    va_end(args);
    
    printf("%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
#endif
}

@end
