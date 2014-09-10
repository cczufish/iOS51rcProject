//
//  AppDelegate.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-8-13.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import "WeiboApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WelcomeViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //shareSDK初始化
    [ShareSDK registerApp:@"2fb76b87ccc8"];
    //添加新浪微博应用 注册网址 http://open.weibo.com
    [ShareSDK connectSinaWeiboWithAppKey:@"3201194191"
                               appSecret:@"0334252914651e8f76bad63337b3b78f"
                             redirectUri:@"http://appgo.cn"];
    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台
    [ShareSDK  connectSinaWeiboWithAppKey:@"568898243"
                                appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                              redirectUri:@"http://www.sharesdk.cn"
                              weiboSDKCls:[WeiboSDK class]];
    
    //添加腾讯微博应用 注册网址 http://dev.t.qq.com
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                redirectUri:@"http://www.sharesdk.cn"
                                   wbApiCls:[WeiboApi class]];
    
    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
    [ShareSDK connectQZoneWithAppKey:@"100371282"
                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    //添加QQ应用  注册网址  http://mobile.qq.com/api/
    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //添加微信应用 注册网址 http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885"
                           wechatCls:[WXApi class]];
    
    //连接邮件 短信
    [ShareSDK connectMail];
    [ShareSDK connectSMS];
    
    //百度地图初始化
    _mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [_mapManager start:@"1NZwnG1MjpMm9W2k8NgddlTg"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //将字典存入到document内
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
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

    //设置欢迎界面
    [NSThread sleepForTimeInterval:1.0];
    //获得是否是第一次登录
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger logCount = [userDefaults integerForKey:@"loginCount"];
    if (logCount == 0) {
        //NSLog(@"the first login");
        //如果是第一次登录，则显示四个欢迎图片
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        WelcomeViewController * startView = [[WelcomeViewController alloc]init];
        self.window.rootViewController = startView;
        [startView release];
    }
    else{
        //NSLog(@"not the first login");
    }
    [self.window makeKeyAndVisible];
    logCount ++;
    [userDefaults setInteger:logCount forKey:@"loginCount"];
    [userDefaults synchronize];
	
    return YES;
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

@end
