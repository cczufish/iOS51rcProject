//
//  PaModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-17.
//

#import "PaModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "CvModifyViewController.h"

@interface PaModifyViewController () <NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@end

@implementation PaModifyViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.viewPa.layer.borderColor = [[UIColor grayColor] CGColor];
    self.viewPa.layer.borderWidth = 1;
    self.viewPa.layer.cornerRadius = 5;
    self.btnSave.layer.cornerRadius = 5;
    [self.scrollPa setContentSize:CGSizeMake(300, 480)];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    
    [self getCvInfo];
}

- (void)getCvInfo
{
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvInfo" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinishedFromCvInfo:(NetWebServiceRequest *)request
                          xmlContent:(GDataXMLDocument *)xmlContent;
{
    NSDictionary *paData = [self getArrayFromXml:xmlContent tableName:@"paData"][0];
    if (!paData[@"LivePlace"]) {
        return;
    }
    [self.txtName setText:paData[@"Name"]];
    [self.btnLivePlace setTitle:paData[@"LiveRegion"] forState:UIControlStateNormal];
    [self.btnAccountPlace setTitle:paData[@"AccountRegion"] forState:UIControlStateNormal];
    [self.btnGrowPlace setTitle:paData[@"GrowRegion"] forState:UIControlStateNormal];
    [self.txtMobile setText:paData[@"Mobile"]];
    [self.lbEmail setText:paData[@"Email"]];
    [self.btnBirth setTitle:[NSString stringWithFormat:@"%@年%@月",[paData[@"BirthDay"] substringWithRange:NSMakeRange(0, 4)],[paData[@"BirthDay"] substringWithRange:NSMakeRange(4, 2)]] forState:UIControlStateNormal];
    
    if ([paData[@"Gender"] isEqualToString:@"false"]) {
        [self.segGender setSelectedSegmentIndex:0];
    }
    else {
        [self.segGender setSelectedSegmentIndex:1];
    }
    [loadView stopAnimating];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    
}

//获取相关表数据
- (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
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
    return arrXml;
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

- (void)dealloc {
    [loadView release];
    [_runningRequest release];
    [_scrollPa release];
    [_viewPa release];
    [_txtName release];
    [_segGender release];
    [_btnBirth release];
    [_btnLivePlace release];
    [_btnLivePlace release];
    [_btnAccountPlace release];
    [_btnGrowPlace release];
    [_txtMobile release];
    [_lbEmail release];
    [_btnSave release];
    [super dealloc];
}
@end
