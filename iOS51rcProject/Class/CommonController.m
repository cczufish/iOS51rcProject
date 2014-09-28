#import "CommonController.h"

@implementation CommonController

+(CGSize)CalculateFrame:(NSString *) content
             fontDemond:(UIFont *) font
             sizeDemand:(CGSize) size
{
    
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize labelSize = [content boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return labelSize;
}

+(NSDate *)dateFromString:(NSString *)dateString{
    NSRange indexOfLength = [dateString rangeOfString:@"T" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    indexOfLength = [dateString rangeOfString:@"+" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString substringToIndex:19];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *thisDate = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return thisDate;
}

+(NSString *)stringFromDate:(NSDate *)date
                 formatType:(NSString *)formatType
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@",formatType]];
    NSString *thisDate = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return thisDate;
}

+(NSString *)stringFromDateString:(NSString *)date
                       formatType:(NSString *)formatType
{
    NSDate *newDate = [self dateFromString:date];
    return [self stringFromDate:newDate formatType:formatType];
}

//是否是空字符串
+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

//检查密码格式
+ (BOOL)checkPassword:(NSString *) strPsd
{
    NSString *passwordreg=@"^[a-zA-Z0-9\\-_\\.]+$";
    NSPredicate *passreg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordreg];
    BOOL ispassWordMatch = [passreg evaluateWithObject:strPsd];
    if(!(ispassWordMatch)){      
        return false;
    }else{
        return true;
    }
}

//验证邮箱
+ (BOOL)checkEmail:(NSString *) strEmail
{
    BOOL result = true;
    NSString * regex = @"^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString *emailReg=@"^[\\.\\-_].*$";
    NSPredicate *email=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    BOOL isEmail=[email evaluateWithObject:strEmail];
    BOOL isMatch = [pred evaluateWithObject:strEmail];
    if(!isMatch){
        //[Dialog alert:@"邮箱格式不正确"];
        result = false;
    }
    if(isEmail){
        result = false;
    }
    
    return result;
}

/*手机号码验证 MODIFIED BY HELENSONG*/
+(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^(13[0-9]|14[0-9]|15[0-9]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL result = [phoneTest evaluateWithObject:mobile];
    return result;
}

+(NSString *)getWeek:(NSDate *)date{
    //return @"";
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSString *strWeek = @"";
    NSInteger week = [comps weekday];
    switch (week){
        case 1:
            strWeek = @"周日";
            break;
        case 2:
            strWeek = @"周一";
            break;
        case 3:
            strWeek = @"周二";
            break;
        case 4:
            strWeek = @"周三";
            break;
        case 5:
            strWeek = @"周四";
            break;
        case 6:
            strWeek = @"周五";
            break;
        case 7:
            strWeek = @"周六";
            break;
        default:
            strWeek = @"周日";
            break;
    }
    [calendar release];
    return strWeek;
}

+(NSString *)getDictionaryDesc:(NSString *)value
               tableName:(NSString *)tableName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    NSString *strDesc = @"";
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    FMResultSet *dictionaryList;
    if ([tableName isEqualToString:@"EmployType"]) {
        dictionaryList = [db executeQuery:[NSString stringWithFormat:@"select * from dcOthers where Category='工作性质' and DetailID=%@",value]];
    }
    else if ([tableName isEqualToString:@"NeedNumber"]) {
        dictionaryList = [db executeQuery:[NSString stringWithFormat:@"select * from dcOthers where Category='招聘人数' and DetailID=%@",value]];
    }
    else if ([tableName isEqualToString:@"Experience"]) {
        dictionaryList = [db executeQuery:[NSString stringWithFormat:@"select * from dcOthers where Category='职位要求工作经验' and DetailID=%@",value]];
    }
    else if([tableName isEqualToString:@"dcNewsType"]){
        dictionaryList = [db executeQuery:[NSString stringWithFormat:@"select * from dcNewsType where OrderNo=%@",value]];
    }
    else {
        dictionaryList = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where _id=%@",tableName,value]];
    }
    while ([dictionaryList next]) {
        strDesc = [dictionaryList stringForColumn:@"description"];
    }
    [db close];
    return strDesc;
}

//获取新闻类别
+(NSMutableArray *)getNewsType:(NSMutableArray *)newsTypeArray
{
    //NSMutableArray *newsTypeArray = [[NSMutableArray alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    FMResultSet *dictionaryList;
    //dictionaryList = [db executeQuery:@"select * from dcNewsType"];
    dictionaryList = [db executeQuery:@"select * from dcNewsType where _id not in (2, 15) order by orderno"];
    [newsTypeArray addObject:@"0"];
    while ([dictionaryList next]) {
        [newsTypeArray addObject:[dictionaryList stringForColumn:@"_id"]];
    }
    [db close];
    return newsTypeArray;
}

+(BOOL)hasParentOfRegion:(NSString *)regionId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    FMResultSet *regionList = [db executeQuery:[NSString stringWithFormat:@"select * from dcRegion where parentid=%@",regionId]];
    BOOL hasRow = [regionList next];
    [db close];
    return hasRow;
}

+(void) execSql:(NSString *)sql
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    [db executeUpdate:sql];
    [db close];
}

+(FMResultSet *) querySql:(NSString *)sql
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    
    FMResultSet *queryList = [db executeQuery:sql];
    return queryList;
}

//过滤Html标签
+ (NSString *) FilterHtml :(NSString*) content
{
    content = [content stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    content = [content stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    content = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"&quot;" withString:@"“"];
    content = [content stringByReplacingOccurrencesOfString:@"<br> <br>" withString:@"\n"];
    content = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    content = [content stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"</b>" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    //content = [content stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n\n"];
    //content = [content stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n\n"];
    //content = [content stringByReplacingOccurrencesOfString:@"<p>" withString:@"\n\n"];
    //content = [content stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n\n"];
    content = [content stringByReplacingOccurrencesOfString:@"&#8226;" withString:@"·"];
    content = [content stringByReplacingOccurrencesOfString:@"<strong>" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"</strong>" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:content];
    NSString *text = nil;
    while([scanner isAtEnd] == NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return content;
}
+ (NSString*)GetCurrentNet
{
    NSString* result;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:// 没有网络连接
            result=nil;
            break;
        case ReachableViaWWAN:// 使用3G网络
            result=@"3g";
            break;
        case ReachableViaWiFi:// 使用WiFi网络
            result=@"wifi";
            break;
    }
    return result;
}

//得到父View
+ (UIViewController *)getFatherController:(UIView *) selfView
{
    for (UIView* next = [selfView superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}

//是否已经登录
+(BOOL) isLogin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"])
        return true;
    else
        return false;
}

//退出登录
+(void) logout{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue: nil forKey:@"UserID"];//PamainID
    [userDefaults setValue:nil forKey:@"paName"];
    //    [userDefaults setValue: nil forKey:@"UserName"];
    //    [userDefaults setValue: nil forKey:@"PassWord"];
    //    [userDefaults setValue: nil forKey:@"BeLogined"];
    //    [userDefaults setBool: false forKey:@"isAutoLogin"];
    //    [userDefaults setValue:nil forKey:@"code"];
    [userDefaults synchronize];
}

//是否是3.5寸屏幕
+(BOOL) is35inchScreen
{
    //判断当前设备屏幕尺寸
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    if (iOSDeviceScreenSize.height == 480) {//3.5寸屏幕
        return YES;
    }
    else{
        return NO;
    }
}
//是否是中文
+(BOOL) isChinese:(NSString *)content
{
    NSString *chineseRegex = @"^[\u4e00-\u9fa5]+$";
    NSPredicate *chineseTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",chineseRegex];
    return [chineseTest evaluateWithObject:content];
}
@end
