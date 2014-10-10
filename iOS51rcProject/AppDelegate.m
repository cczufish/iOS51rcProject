#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import "WeiboApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WelcomeViewController.h"
#import "CommonController.h"
#import "BPush.h"

@implementation AppDelegate
@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [CommonController execSql:@"delete from dcsalary where _id=1"];
    
    //百度地图初始化
    _mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [_mapManager start:@"6EaXjB5c8pkW5Gm0KL9QEIpD"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //将字典存入到document内
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    NSFileManager *file = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:dbPath]) {
        
    }
    else {
        NSString *originDbPath = [[NSBundle mainBundle] pathForResource:@"dictionary.db" ofType:nil];
        NSData *mainBundleFile = [NSData dataWithContentsOfFile:originDbPath];
        [file createFileAtPath:dbPath contents:mainBundleFile attributes:nil];
    }
    
    //判断当前设备屏幕尺寸
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    UIStoryboard *mainStoryboard = nil;
    mainStoryboard = self.window.rootViewController.storyboard;
    mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    if (iOSDeviceScreenSize.height == 568) {//IPhone 5
        mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    }
    else{
        mainStoryboard = self.window.rootViewController.storyboard;
    }
    
    MenuViewController *menuC = (MenuViewController*)[mainStoryboard
                                                      instantiateViewControllerWithIdentifier: @"MenuView"];
	[SlideNavigationController sharedInstance].rightMenu = menuC;
	[SlideNavigationController sharedInstance].leftMenu = menuC;

    //设置推送
    [BPush setupChannel:launchOptions];
    [BPush setDelegate:self];
#if SUPPORT_IOS8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
#endif
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }

    //推送绑定
    [BPush bindChannel];
    //设置欢迎界面
    [NSThread sleepForTimeInterval:1.0];
    //获得是否是第一次登录
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger logCount = [userDefaults integerForKey:@"loginCount"];
    if (logCount > 0) {
        WelcomeViewController * startView = [[WelcomeViewController alloc] init];
        [self.window.rootViewController.view addSubview:startView.view];    }
    else{
        //NSLog(@"not the first login");
    }
    
    logCount++;
    [userDefaults setInteger:logCount forKey:@"loginCount"];
    if (![userDefaults objectForKey:@"subSiteId"]) {
        [userDefaults setValue:@"32" forKey:@"subSiteId"];
        [userDefaults setValue:@"齐鲁人才网" forKey:@"subSiteName"];
        [userDefaults setValue:@"山东" forKey:@"subSiteCity"];
        [userDefaults setValue:@"http://www.qlrc.com" forKey:@"subSiteUrl"];
    }
    if (![userDefaults objectForKey:@"sqlVersion"]) {
        [userDefaults setValue:@"2" forKey:@"sqlVersion"];
    }
    [userDefaults setBool:YES forKey:@"firstToHome"];
    [userDefaults synchronize];
    
    NSString *redirectUri = [userDefaults objectForKey:@"subSiteUrl"];
    redirectUri = [redirectUri stringByReplacingOccurrencesOfString:@"www" withString:@"m"];
    //shareSDK初始化
    [ShareSDK registerApp:@"2fb76b87ccc8"];
//    //添加新浪微博应用 注册网址 http://open.weibo.com
//    [ShareSDK connectSinaWeiboWithAppKey:@"447347256"
//                               appSecret:@"b9ecb3915e3e9cfc333dafbb74e9d336"
//                             redirectUri:redirectUri];
//    
//    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台
//    [ShareSDK  connectSinaWeiboWithAppKey:@"447347256"
//                                appSecret:@"b9ecb3915e3e9cfc333dafbb74e9d336"
//                              redirectUri:redirectUri
//                              weiboSDKCls:[WeiboSDK class]];
    
    [ShareSDK connectTencentWeiboWithAppKey:@"801542718"
                                  appSecret:@"4b77146e2165df1b5d0f8312ee8757f3"
                                redirectUri:redirectUri
                                   wbApiCls:[WeiboApi class]];
    
//    [ShareSDK connectQZoneWithAppKey:@"801542718"
//                           appSecret:@"4b77146e2165df1b5d0f8312ee8757f3"
//                   qqApiInterfaceCls:[QQApiInterface class]
//                     tencentOAuthCls:[TencentOAuth class]];

    [ShareSDK connectQQWithQZoneAppKey:@"801542718"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    [ShareSDK connectWeChatWithAppId:@"wx06c592bc41506c42"
                           wechatCls:[WXApi class]];
    [ShareSDK importWeChatClass:[WXApi class]];
    
    //连接邮件 短信
    [ShareSDK connectMail];
    [ShareSDK connectSMS];
    
	[self.window makeKeyAndVisible];
    return YES;
}

#if SUPPORT_IOS8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
#endif

//如果注册成功，APNs会返回给你设备的token
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"My token is:%@", deviceToken);
    [BPush registerDeviceToken: deviceToken];
}

//注册失败
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"Failed to get token, error:%@", error_str);
}

- (void) onMethod:(NSString*)method response:(NSDictionary*)data {
    NSLog(@"On method:%@", method);
    NSLog(@"data:%@", [data description]);
    NSDictionary* res = [[[NSDictionary alloc] initWithDictionary:data] autorelease];
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        //NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        //NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        //NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        //NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];        
        if (returnCode == BPushErrorCode_Success) {
            // 在内存中备份，以便短时间内进入可以看到这些值，而不需要重新bind
            // self.appId = appid;
            // self.channelId = channelid;
            // self.userId = userid;
        }
    } else if ([BPushRequestMethod_Unbind isEqualToString:method]) {
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode == BPushErrorCode_Success) {
           
        }
    }

}

//收到推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //NSLog(@"Receive Notify: %@", [userInfo JSONString]);
    //NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
    }
    [application setApplicationIconBadgeNumber:0];
    
    [BPush handleNotification:userInfo];
}

-(void)setAnimation:(UIImageView *)nowView
{
    
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionCurveLinear
                     animations:^
     {
         // 执行的动画code
         [nowView setFrame:CGRectMake(nowView.frame.origin.x- nowView.frame.size.width*0.1, nowView.frame.origin.y-nowView.frame.size.height*0.1, nowView.frame.size.width*1.2, nowView.frame.size.height*1.2)];
     }
                     completion:^(BOOL finished)
     {
         // 完成后执行code
         [nowView removeFromSuperview];
     }
     ];
    
    
}

- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
