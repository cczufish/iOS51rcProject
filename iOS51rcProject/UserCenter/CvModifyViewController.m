//
//  CvModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-15.
//

#import "CvModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"

@interface CvModifyViewController ()<NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
    float fltHeight;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSArray *cvData;

@end

@implementation CvModifyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@",self.cvId);
}

- (void)getCvInfo
{
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetBasicCvListByPaMainID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    
}

- (void)netRequestFinishedFromCvInfo:(NetWebServiceRequest *)request
                          xmlContent:(GDataXMLDocument *)xmlContent
{
    self.cvData = [xmlContent nodesForXPath:@"//Table1" error:nil];
    [self getCvBasic:[xmlContent nodesForXPath:@"//paData" error:nil]];
    [self getCvEducation:[xmlContent nodesForXPath:@"//Table2" error:nil]];
    [self getCvExperience:[xmlContent nodesForXPath:@"//Table3" error:nil]];
    [self getCvIntention:[xmlContent nodesForXPath:@"//Table4" error:nil]];
}

- (void)getCvBasic:(NSArray *)arrayCvBasic
{
    
}

- (void)getCvEducation:(NSArray *)arrayCvEducation
{
    
}

- (void)getCvExperience:(NSArray *)arrayCvExperience
{
    
}

- (void)getCvIntention:(NSArray *)arrayCvIntention
{
    
}

- (void)getCvSpecaility:(NSArray *)arrayCvLanguage
{
    
}

//获取相关表数据
- (void)getArrayFromXml:(GDataXMLDocument *)xmlContent
              tableName:(NSString *)tableName
{
    NSArray *xmlTable = [xmlContent nodesForXPath:[NSString stringWithFormat:@"//%@", tableName] error:nil];
    NSMutableArray *arrXml = [[NSMutableArray alloc] init];
    for (int i=0; i<xmlTable.count; i++) {
        GDataXMLElement *oneXmlElement = [xmlTable objectAtIndex:i];
        NSArray *arrChild = [oneXmlElement children];
        NSMutableDictionary *dicOneXml = [[NSMutableDictionary alloc] init];
        for (int j=0; j<arrChild.count; j++) {
            [dicOneXml setObject:[arrChild[j] stringValue] forKey:[arrChild[j] name]];
        }
        [arrXml addObject:dicOneXml];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
