#import "UserInfo.h"

//用户信息
@implementation UserInfo

//退出登录
+(BOOL) logout{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue: nil forKey:@"UserID"];//PamainID
    [userDefaults setValue: nil forKey:@"UserName"];
    [userDefaults setValue: nil forKey:@"PassWord"];
    [userDefaults setValue: nil forKey:@"BeLogined"];
    [userDefaults setBool: false forKey:@"isAutoLogin"];
    [userDefaults setObject:nil forKey:@"code"];

    return true;
}

//是否已经登录
+(BOOL) isLogin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"])
        return true;
    else
        return false;
}

@end
