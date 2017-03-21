//
//  GetuiForUnity.h
//  Unity3D
//
//  Created by dazq on 16/7/1.
//  Copyright © 2016年 dzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeTuiSdk.h"

#if defined(__cplusplus)
extern "C"{
#endif
    extern void UnitySendMessage(const char  *, const char  *, const char  *);
#if defined(__cplusplus)
}
#endif

@interface GetuiForUnity : NSObject<GeTuiSdkDelegate>

+ (void)sendU3dMessage:(NSString *)messageName param:(NSDictionary *)dict;
-(void)setListenerGameObject:(NSString *)GameObjectName;
+(void)registerUserNotification;
@end
