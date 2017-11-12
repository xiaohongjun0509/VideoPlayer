//
//  Utils.m
//  VideoPlayerKit
//
//  Created by xiaohongjun on 2017/11/3.
//  Copyright © 2017年 xiaohongjun. All rights reserved.
//

#import "Utils.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation Utils

+ (NSString *)fileMD5:(NSString *)string
{
    const char *data = [string UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data, (CC_LONG)strlen(data), result);
    NSMutableString *mString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        //02:不足两位前面补0,   %02x:十六进制数
        [mString appendFormat:@"%02x",result[i]];
    }
    return mString;
}

@end
