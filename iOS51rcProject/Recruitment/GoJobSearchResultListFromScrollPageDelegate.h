#import <Foundation/Foundation.h>

@protocol GoJobSearchResultListFromScrollPageDelegate <NSObject>
-(void) GoJobSearchResultListFromScrollPage:(NSString*) strSearchRegion SearchJobType:(NSString*) strSearchJobType SearchIndustry:(NSString *) strSearchIndustry SearchKeyword:(NSString *) strSearchKeyword SearchRegionName:(NSString *) strSearchRegionName SearchJobTypeName:(NSString *) strSearchJobTypeName SearchCondition:(NSString *) strSearchCondition;
@end
