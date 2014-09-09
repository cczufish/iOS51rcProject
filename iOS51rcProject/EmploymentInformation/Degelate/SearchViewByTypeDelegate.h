#import <Foundation/Foundation.h>

@protocol SearchViewByTypeDelegate <NSObject>
-(void) searchNewsByType:(NSString *) newsType;
@end
