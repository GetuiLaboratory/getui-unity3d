//
//  GetuiForUnity.m
//  Unity3D
//
//  Created by dazq on 16/7/1.
//  Copyright © 2016年 dzq. All rights reserved.
//

#import "GetuiForUnity.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <PushKit/PushKit.h>
#import "GeTuiSdk.h"
#import "AppDelegateListener.h"

@interface GetuiForUnity () <AppDelegateListener, GeTuiSdkDelegate, PKPushRegistryDelegate>

@property (nonatomic, strong) NSDictionary *launchOptions;

/**
 *  设置接收 UnitySendMessage 的 GameObject
 *
 *  @param GameObjectName GameObject 名称
 */
@property (nonatomic, copy) NSString *gameObjectName;

@end

@implementation GetuiForUnity

+ (void)load
{
    [GetuiForUnity sharedInstance];
}

+ (instancetype)sharedInstance
{
    static GetuiForUnity *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GetuiForUnity alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        UnityRegisterAppDelegateListener(self);
    }
    return self;
}

- (void)dealloc
{
    UnityUnregisterAppDelegateListener(self);
}

- (void)applicationWillFinishLaunchingWithOptions:(NSNotification*)notification
{
    self.launchOptions = notification.userInfo;
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSNotification*)notification
{
    NSData *data = (id)notification.userInfo;
    if ([data isKindOfClass:[NSData class]]) {
        [GeTuiSdk registerDeviceTokenData:data];
    }
}

#pragma mark --

//message tools
- (NSString *)gameObjectName
{
    if (!_gameObjectName) {
        _gameObjectName = @"Main Camera";
    }
    return _gameObjectName;
}

+ (void)sendU3dMessage:(NSString *)messageName param:(id)dict {
    NSString *param = @"";
    if ([dict isKindOfClass:[NSDictionary class]]) {
        param = [self DataTOjsonString:dict];
    } else {
        param = dict;
    }
    UnitySendMessage([[GetuiForUnity sharedInstance].gameObjectName UTF8String], [messageName UTF8String], [param UTF8String]);
}

+ (NSString *)DataTOjsonString:(id)object {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - Getui Delegate

- (void)GeTuiSdkDidReceiveNotification:(NSDictionary *)userInfo notificationCenter:(UNUserNotificationCenter *)center response:(UNNotificationResponse *)response fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         userInfo, @"msg", nil];
    [GetuiForUnity sendU3dMessage:@"onNotificationMessageClicked" param:ret];
    if (completionHandler) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)GeTuiSdkDidReceiveSlience:(NSDictionary *)userInfo fromGetui:(BOOL)fromGetui offLine:(BOOL)offLine appId:(NSString *)appId taskId:(NSString *)taskId msgId:(NSString *)msgId fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // [4]: 收到透传消息
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"payload", @"type",
                                          taskId, @"taskId",
                                          msgId, @"messageId",
                         userInfo[@"payload"] ? :@"", @"payload",
                         offLine ? @"true" : @"false", @"offLine", nil];
    [GetuiForUnity sendU3dMessage:@"onReceiveMessage" param:ret];
    if(completionHandler) {
        // [ 参考代码，开发者注意根据实际需求自行修改 ] 根据APP需要自行修改参数值
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    [GetuiForUnity sendU3dMessage:@"onReceiveClientId" param:clientId];
}

- (void)GeTuiSdkDidOccurError:(NSError *)error {

    [GetuiForUnity sendU3dMessage:@"GeTuiSdkDidOccurError" param:[NSString stringWithFormat:@"%@", error]];
}

- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    [GetuiForUnity sendU3dMessage:@"GeTuiSdkDidSetPushMode" param:!isModeOff ? @"true" : @"false"];
}

- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    [GetuiForUnity sendU3dMessage:@"GeTuiSDkDidNotifySdkState" param:[NSString stringWithFormat:@"%ld", aStatus]];
}

- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError {

    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                                          action, @"action",
                                          isSuccess ? @"true" : @"false", @"result",
                                          aSn, @"sequenceNum",
                                          aError, @"error", nil];

    [GetuiForUnity sendU3dMessage:@"GeTuiSdkDidAliasAction" param:ret];
}

/** 注册用户通知 */
+ (void)registerUserNotification {
    // [ 参考代码，开发者注意根据实际需求自行修改 ] 注册远程通知
    [GeTuiSdk registerRemoteNotification: (UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge)];
}

#pragma mark - VOIP related

// 实现 PKPushRegistryDelegate 协议方法

/** 系统返回VOIPToken，并提交个推服务器 */

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
    NSString *voiptoken = [credentials.token.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    voiptoken = [voiptoken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[VoIP Token]:%@\n\n",voiptoken);
    //向个推服务器注册 VoipToken
    [GeTuiSdk registerVoipToken:voiptoken];
}

/** 接收VOIP推送中的payload进行业务逻辑处理（一般在这里调起本地通知实现连续响铃、接收视频呼叫请求等操作），并执行个推VOIP回执统计 */
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    //个推VOIP回执统计
    [GeTuiSdk handleVoipNotification:payload.dictionaryPayload];
    
    //TODO:接受 VoIP 推送中的 payload 内容进行具体业务逻辑处理
    NSLog(@"[VoIP Payload]:%@,%@", payload, payload.dictionaryPayload);
    
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInteger:1], @"result",
                         @"voipPayload", @"type",
                         payload.dictionaryPayload[@"payload"], @"payload",
                         payload.dictionaryPayload[@"_gmid_"], @"gmid",  nil];
    [GetuiForUnity sendU3dMessage:@"onReceiveVoIPMessage" param:ret];
}

@end

// Converts C style string to NSString
NSString *GTCreateNSString(const char *string) {
    if (string)
        return [NSString stringWithUTF8String:string];
    else
        return [NSString stringWithUTF8String:""];
}

// Helper method to create C string copy
char *GTMakeStringCopy(const char *string) {
    if (string == NULL)
        return NULL;

    char *res = (char *) malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

// When native code plugin is implemented in .mm / .cpp file, then functions
// should be surrounded with extern "C" block to conform C function naming rules

// By default mono string marshaler creates .Net string for returned UTF-8 C string
// and calls free for returned value, thus returned strings should be allocated on heap
#if defined(__cplusplus)
extern "C" {
#endif
void _StartSDK(const char *appId, const char *appKey, const char *appSecret) {
    [GeTuiSdk startSdkWithAppId:GTCreateNSString(appId) appKey:GTCreateNSString(appKey) appSecret:GTCreateNSString(appSecret) delegate:[GetuiForUnity sharedInstance] launchingOptions:[GetuiForUnity sharedInstance].launchOptions];
    [GetuiForUnity sharedInstance].launchOptions = nil;
    
}
void _registerUserNotification() {
    [GetuiForUnity registerUserNotification];
}
void _setListenerGameObject(const char *gameObjectName) {
    [GetuiForUnity sharedInstance].gameObjectName = GTCreateNSString(gameObjectName);
}

void _registerDeviceToken(const char *token) {
//    NSString *deviceToken = GTCreateNSString(token);
//    [GeTuiSdk registerDeviceToken:deviceToken];
}

const char *_clientId(const char *alias) {
    return GTMakeStringCopy([[GeTuiSdk clientId] UTF8String]);
}

void _destroy() {
    [GeTuiSdk destroy];
}
void _resume() {
    [GeTuiSdk resume];
}
void _bindAlias(const char *alias, const char *aSn) {
    [GeTuiSdk bindAlias:GTCreateNSString(alias) andSequenceNum:GTCreateNSString(aSn)];
}
const int _status() {
    return (int)[GeTuiSdk status];
}
void _unBindAlias(const char *alias, const char *aSn) {
    [GeTuiSdk unbindAlias:GTCreateNSString(alias) andSequenceNum:GTCreateNSString(aSn) andIsSelf:YES];
}
const char *_version() {
    return GTMakeStringCopy([[GeTuiSdk version] UTF8String]);
}
const bool _setTag(const char *tags) {
    NSArray *tagsArray = [GTCreateNSString(tags) componentsSeparatedByString:@","];
    return [GeTuiSdk setTags:tagsArray];
}
void _setPushMode(const bool isValue) {
    [GeTuiSdk setPushModeForOff:!isValue];
}
void _runBackgroundEnable(const bool isEnable) {
    [GeTuiSdk runBackgroundEnable:isEnable];
}
/**
     *  设置渠道
     *  备注：SDK可以未启动就调用该方法
     *
     *  SDK-1.5.0+
     *
     *  @param aChannelId 渠道值，可以为空值
     */
void _setChannelId(const char *aChannelId) {
    [GeTuiSdk setChannelId:GTCreateNSString(aChannelId)];
}
    
void _voipRegistration() {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:mainQueue];
    voipRegistry.delegate = [GetuiForUnity sharedInstance];
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

#if defined(__cplusplus)
}
#endif


