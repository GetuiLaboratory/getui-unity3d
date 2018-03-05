# Getui-Unity3D
这是个推官方支持的 Unity3D 插件（Android & iOS）。更多详情请访问个推官网：[http://docs.getui.com/](http://docs.getui.com/)。
## 1. 添加插件

1. 确保使用 Unity 打开需要集成本插件的 Unity3D 工程

2. 运行插件目录下的 GTPushUnityPlugin_vX.X.X.unitypackage

插件将会自动添加到 Unity3D 工程中，完成插件的添加。


## 2. demo 脚本的挂载
在 Unity 游戏场景中，新建一个空的 `Gameobject`，挂载 `GetuiPushDemo.cs`（或者直接挂载到 `Main Camera`），然后根据项目需要对 `GetuiPushDemo.cs` 中的个推推送功能进行定制，其中有某些参数需要到个推官网注册生成并引用。（[个推开发者平台](https://dev.getui.com/dos4.0/index.html#login)）

## 3. Android 插件使用
- 替换 `Assets/Plugins/Android/AndroidManifest.xml`里的包名。

- 将 `Assets/Plugins/Android/AndroidManifest.xml`里对应的`PUSH_APPID`,`PUSH_APPKEY`,`AUSH_APPSECRET`的值替换成在个推控制台应用配置中获得的对应值。

- 如果其他插件已经存在 AndroidManifest.xml 文件，请自行进行配置合并。

- 如果您还未配置您的游戏的`Bundle Idenifier`, 在 Unity 中选择 *File---Build Settings---选择Android Player图标--Player Settings*，在 *Identification* 选项下的 *Bundle Idenifier* 里设置应用的包名。

- 如果您还未设置您的游戏的 Icon，在 Unity 中选择 *File---Build Settings---选择Android Player图标--Player Settings*，在*Identification* 选项下的 *Icon* 里设置图标。

- 如果您需要运行该插件的示例代码，在 Unity 中将`Assets/GTPluginsDemo.cs`用鼠标拖动到`Main Camera`中（运行后可在Logcat中查看调用日志）。

- 如果您需要立即在您自己的游戏中使用插件，请删除`Assets/Plugins/Android/AndroidManifest.xml`中标志有`  <!-- For test only. 测试的主程序 -->`的Activity注册代码。

- 在`Assets/Plugins/Android/res/drawable-xxxx/`替换push.png(该图片为通知栏通知的图标)

## 4. iOS 插件使用

1、以下几个参数需要在个推开发者平台创建应用后获取并替换。

```
const string appId = "tHrR9RAVKK9npDDGK7tHp6";
const string appKey = "CyiCeSdnJB6N0O0hvziYe8";
const string appSecret = "HGuR9YU1Cq7BUXGXBhbLf7";
```

```
//iOS 启用流程
//启动 SDK
GetuiPush.StartSDK (appId,appKey,appSecret);
//设置消息回调监听对象，设置为自身，默认为 Main Camera
GetuiPush.setListenerGameObject (this.gameObject.name);
//注册推送通知
GetuiPush.registerUserNotification ();
// 注册 VoIP 通知
GTPushBinding.voipRegistration();
```
```
//在 update() 方法中获取到系统注册的 deviceToken
void Update () {
		#if UNITY_IPHONE
		if (!tokenSent) {
			byte[] token = NotificationServices.deviceToken;
			if (token != null) {
				// send token to a provider
				string deviceToken = System.BitConverter.ToString(token).Replace("-","");
				// 在个推插件中注册 deviceToken，完成个推注册
				GTPushBinding.registerDeviceToken (deviceToken);
			}
		}
		#endif
	}
```
更多细节请参考 demo

2、生成 iOS 工程，并打开该工程。

添加必要的框架。

* libc++.tbd
* libz.tbd
* libsqlite3.tbd
* UserNotifications.framework
* PushKit.framework

> 注意：UserNotifications.framework 及 PushKit.framework 必须使用 optional 选项，如没有勾选改选项，iOS9 以下机型会因为没有这个库而闪退

Unity3D 有时候会默认添加以下几个 framework，视具体版本而定，如没有需手动添加：

* Security.framework
* MobileCoreServices.framework
* SystemConfiguration.framework
* CoreTelephony.framework
* AVFoundation.framework
* CoreLocation.framework

3、在 Xcode 8.x 以上，必须开启Push Notification能力。找到应用Target设置中的Capabilities -> Push Notifications，确认开关已经设为ON状态。如果没有开启该开关，在 Xcode 8.x 上编译后的应用将获取不到DeviceToken：

![](http://docs.getui.com/img/img_getui_mobile_ios_xcode_9.png)

为了更好支持消息推送，SDK可定期抓取离线消息，提高消息到达率，需要配置后台运行权限：

![](http://docs.getui.com/img/img_getui_mobile_ios_xcode_10.png)

4、iOS 推送证书配置请参考：[创建 APNs 推送证书](http://docs.getui.com/mobile/ios/apns/)

5、v_1.0.9 版本开始支持 VoIP 推送，需要添加后台推送 VoIP 的权限，在 info.plist 文件的后台权限中添加该权限：

![VoIP 权限配置](https://github.com/GetuiLaboratory/react-native-getui/blob/master/example/document/img/ios_1.jpeg?raw=true)

# API 使用说明
> 由于 iOS & Android 注册推送的流程不一样，因此注册流程所暴露的 API 不一致。此外，iOS 有更多的回调接口，也需要注意区别使用。

### iOS & Android

```
/**
 *  SDK登入成功返回clientId
 *
 *  @param clientId 标识用户的clientId
 *  说明:启动GeTuiSdk后，SDK会自动向个推服务器注册SDK，当成功注册时，SDK通知应用注册成功。
 *  注意: 注册成功仅表示推送通道建立，如果appid/appkey/appSecret等验证不通过，依然无法接收到推送消息，请确保验证信息正确。
 */
	public void onReceiveClientId(string clientId){
		GTPushBinding.setPushMode (true);
		Debug.Log ("GeTuiSdkDidRegisterClient clientId : " + clientId);
	}

	/**
 *  SDK通知收到个推推送的透传消息
 *
 *  @param payload 推送消息内容
 *  @param taskId      推送消息的任务id
 *  @param msgId       推送消息的messageid
 *  @param offLine     是否是离线消息，YES.是离线消息 （Android无此字段）
 *  @param appId       应用的appId (Android无此字段)
 */
	public void onReceiveMessage(string payloadJsonData){
		Debug.Log ("GeTuiSdkDidReceivePayloadData payload JsonData : " + payloadJsonData);
	}
```

### iOS API
```
GTPushBinding.StartSDK (appId,appKey,appSecret);
GTPushBinding.setListenerGameObject (this.gameObject.name);
GTPushBinding.registerUserNotification ();
GTPushBinding.voipRegistration();

```

### iOS 回调

````
	/**
 *  SDK设置关闭推送模式回调
 *
 *  @param isModeOn true：开启 false：关闭
 */
	public void GeTuiSdkDidSetPushMode(string isModeOn){
		Debug.Log ("GeTuiSdkDidSetPushMode isModeOn : " + isModeOn);
	}
	/**
 *  SDK遇到错误消息返回error
 *
 *  @param error SDK内部发生错误，通知第三方，返回错误
 */
	public void GeTuiSdkDidOccurError(string error){
		Debug.Log ("GeTuiSdkDidOccurError error : " + error);
	}

	/**
	 *  SDK运行状态通知
	 *
	 *  @param message 返回SDK运行状态
	 */
	public void GeTuiSDkDidNotifySdkState(string state){
		Debug.Log ("GeTuiSDkDidNotifySdkState state : " + state);
	}

	/**
	 *  SDK绑定、解绑回调
	 *
	 *  @param action       回调动作类型 kGtResponseBindType 或 kGtResponseUnBindType
	 *  @param result    成功返回 YES, 失败返回 NO
	 *  @param sequenceNum          返回请求的序列码
	 *  @param error       成功返回nil, 错误返回相应error信息
	 */

	public void GeTuiSdkDidAliasAction(string message){
		Debug.Log ("GeTuiSdkDidAliasAction message : " + message);
	}

	// VoIP 推送消息回调
	public void onReceiveVoIPMessage(string message){
		Debug.Log ("onReceiveVoIPMessage message : " + message);
	}
````

### Android API
```
GTPushBinding.initPush (this.gameObject.name));
GTPushBinding.turnOnPush();
```

更多 API 详情请参考 [GTPushBinding.cs](https://github.com/GetuiLaboratory/getui-unity3d/blob/master/Plugins/GTPushBinding.cs) 相同方法名的方法说明，以及在 [GetuiPushDemo.cs](https://github.com/GetuiLaboratory/getui-unity3d/blob/master/Example/GetuiPushDemo.cs) 中的相关使用示例。
