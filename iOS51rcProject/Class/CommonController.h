#import <UIKit/UIKit.h>

@interface CommonController : NSObject

+(CGSize)CalculateFrame:(NSString*) content
             fontDemond:(UIFont*) font
             sizeDemand:(CGSize) size;

+(NSDate *)dateFromString:(NSString *)dateString;
+(NSString *)getWeek:(NSDate *)date;
+(NSString *)stringFromDate:(NSDate *)date
                 formatType:(NSString *)formatType;
+(BOOL)checkPassword:(NSString *) strPsd;
//+(BOOL) checkPassword:(NSString *) strPsd;
+(BOOL) isBlankString:(NSString *)string;
-(BOOL)isMobileNumber:(NSString *)mobileNum;
-(BOOL) checkEmail:(NSString *) userName;
+(BOOL) isValidateMobile:(NSString *)mobile;
+(NSString *)getDictionaryDesc:(NSString *)value
               tableName:(NSString *)tableName;
@end
