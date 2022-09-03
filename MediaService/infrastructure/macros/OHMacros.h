//
//  OHMacros.h
//  MediaService
//
//  Created by 梁甜 on 2022/9/3.
//

#import <Foundation/Foundation.h>

#ifndef OHSuppressPerformSelectorLeakWarningBegin
#define OHSuppressPerformSelectorLeakWarningBegin _Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
#endif

#ifndef OHSuppressPerformSelectorLeakWarningEnd
#define OHSuppressPerformSelectorLeakWarningEnd _Pragma("clang diagnostic pop")
#endif
