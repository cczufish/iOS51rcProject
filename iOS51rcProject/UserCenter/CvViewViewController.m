//
//  CvViewViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-15.
//

#import "CvViewViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "CustomPopup.h"
#import "CommonController.h"

@interface CvViewViewController ()<NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
    float fltHeight;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSArray *cvData;
@property (nonatomic, retain) NSArray *paData;
@property (nonatomic, retain) NSArray *intentionData;
@property (nonatomic, retain) CustomPopup *cPopup;

@end

@implementation CvViewViewController

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
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [loadView startAnimating];
    
    //获取数据
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

- (void)getPaBasic
{
    if (!self.paData[0][@"BirthDay"]) {
        return;
    }
    [self.lbPaName setText:self.paData[0][@"Name"]];
    CGSize lableSize = [CommonController CalculateFrame:self.lbPaName.text fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(800, 15)];
    CGRect framePaName = self.lbPaName.frame;
    framePaName.size.width = lableSize.width;
    [self.lbPaName setFrame:framePaName];
    
    CGRect frameViewPaBasic = self.viewPaBasic.frame;
    frameViewPaBasic.origin.x = framePaName.origin.x + framePaName.size.width + 15;
    [self.viewPaBasic setFrame:frameViewPaBasic];
    
    [self.lbBirth setText:[NSString stringWithFormat:@"%@岁",self.paData[0][@"Age"]]];
    if (self.paData[0][@"MobileVerifyDate"]) {
        [self.imgMobileCer setImage:[UIImage imageNamed:@"ico_member_moblecer.png"]];
        [self.lbMobileCer setText:@"手机已认证"];
    }
    [self.lbLivePlace setText:self.paData[0][@"LiveRegion"]];
    [self.lbAccountPlace setText:self.paData[0][@"AccountRegion"]];
    [self.lbGrowPlace setText:self.paData[0][@"GrowRegion"]];
    [self.lbMobile setText:[NSString stringWithFormat:@"%@（%@）",self.paData[0][@"Mobile"],self.paData[0][@"MobileRegion"]]];
    [self.lbMobile2 setText:[NSString stringWithFormat:@"%@（%@）",self.paData[0][@"Mobile"],self.paData[0][@"MobileRegion"]]];
    [self.lbEmail setText:self.paData[0][@"Email"]];
    [self.lbEmail2 setText:self.paData[0][@"Email"]];
    
    if ([self.paData[0][@"Gender"] isEqualToString:@"false"]) {
        [self.lbGender setText:@"男"];
    }
    else {
        [self.lbGender setText:@"女"];
    }
    self.lbLoginDate.text = [CommonController stringFromDateString:self.paData[0][@"LastLoginDate"] formatType:@"yyyy-MM-dd HH:mm"];
    self.lbRefreshDate.text = [CommonController stringFromDateString:self.cvData[0][@"RefreshDate"] formatType:@"yyyy-MM-dd HH:mm"];
    if (self.paData[0][@"PhotoProcessed"])
    {
        if (![self.paData[0][@"HasPhoto"] isEqualToString:@"2"]) {
            NSString *path = [NSString stringWithFormat:@"%d",([[self.userDefaults objectForKey:@"UserID"] intValue] / 100000 + 1) * 100000];
            for (int i=0; i<9-path.length; i++) {
                path = [NSString stringWithFormat:@"0%@",path];
            }
            path = [NSString stringWithFormat:@"L%@",path];
            path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Photo/%@/Processed/%@",path,self.paData[0][@"PhotoProcessed"]];
            [self.imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]]];
        }
    }
}

- (void)getJobIntention:(NSArray *)arrayCvIntention
{
    self.intentionData = arrayCvIntention;
    CGRect frameViewJobIntention = self.viewJobIntention.frame;
    [self.lbEmployType setText:[CommonController getDictionaryDesc:arrayCvIntention[0][@"EmployType"] tableName:@"EmployType"]];
    if ([arrayCvIntention[0][@"IsNegotiable"] isEqualToString:@"true"]) {
        [self.lbSalary setText:[NSString stringWithFormat:@"%@（可面议）",arrayCvIntention[0][@"Salary"]]];
    }
    else {
        [self.lbSalary setText:arrayCvIntention[0][@"Salary"]];
    }
    
    CGSize labelSize = [CommonController CalculateFrame:arrayCvIntention[0][@"JobTypeName"] fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(160, 300)];
    [self.lbExpectJobType setText:arrayCvIntention[0][@"JobTypeName"]];
    if (labelSize.height > 20) {
        CGRect frameExpectJobType = self.lbExpectJobType.frame;
        frameExpectJobType.size.height = labelSize.height;
        [self.lbExpectJobType setFrame:frameExpectJobType];
        //修改求职意向view的高度
        frameViewJobIntention.size.height += labelSize.height-15;
        //位置下移
        CGRect frameIntention1 = self.viewIntention1.frame;
        frameIntention1.origin.y += labelSize.height-15;
        [self.viewIntention1 setFrame:frameIntention1];
        
        CGRect frameIntention2 = self.viewIntention2.frame;
        frameIntention2.origin.y += labelSize.height-15;
        [self.viewIntention2 setFrame:frameIntention2];
    }
    
    labelSize = [CommonController CalculateFrame:arrayCvIntention[0][@"JobPlaceName"] fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(160, 300)];
    [self.lbExpectJobPlace setText:arrayCvIntention[0][@"JobPlaceName"]];
    if (labelSize.height > 20) {
        //期望职位类别多行，将下面的控件位置处理
        CGRect frameExpectJobPlace = self.lbExpectJobPlace.frame;
        frameExpectJobPlace.size.height = labelSize.height;
        [self.lbExpectJobPlace setFrame:frameExpectJobPlace];
        //修改求职意向view的高度
        frameViewJobIntention.size.height += labelSize.height-15;
        //位置下移
        CGRect frameIntention2 = self.viewIntention2.frame;
        frameIntention2.origin.y += labelSize.height-15;
        [self.viewIntention2 setFrame:frameIntention2];
    }
    [self.viewJobIntention setFrame:frameViewJobIntention];
    [self.scrollCvView setContentSize:CGSizeMake(320, self.viewJobIntention.frame.origin.y+self.viewJobIntention.frame.size.height)];
}

- (void)getCvSpecaility
{
    [self.lbSpeciality setText:self.cvData[0][@"Speciality"]];
    //计算工作能力文本的高度
    CGSize labelSize = [CommonController CalculateFrame:self.cvData[0][@"Speciality"] fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(270, 3000)];
    CGRect frameSpeciality = self.lbSpeciality.frame;
    frameSpeciality.size.height = labelSize.height;
    [self.lbSpeciality setFrame:frameSpeciality];
    //修改工作能力view的高度和Y
    CGRect frameViewSpeciality = self.viewSpeciality.frame;
    frameViewSpeciality.size.height += labelSize.height-15;
    CGSize sizeScroll = self.scrollCvView.contentSize;
    frameViewSpeciality.origin.y = sizeScroll.height;
    [self.viewSpeciality setFrame:frameViewSpeciality];
    sizeScroll.height = self.viewSpeciality.frame.origin.y+self.viewSpeciality.frame.size.height;
    [self.scrollCvView setContentSize:sizeScroll];
}

- (void)getCvEducation:(NSArray *)arrayCvEducation
{
    float heightViewEduAndExp = 42;
    for (NSDictionary *dicEducation in arrayCvEducation) {
        heightViewEduAndExp = [self fillCvEducation:dicEducation contentHeight:heightViewEduAndExp];
    }
    //修改位置和高度
    CGRect frameViewEduAndExp = self.viewEduAndExp.frame;
    frameViewEduAndExp.size.height = heightViewEduAndExp;
    CGSize sizeScroll = self.scrollCvView.contentSize;
    frameViewEduAndExp.origin.y = sizeScroll.height;
    [self.viewEduAndExp setFrame:frameViewEduAndExp];
    sizeScroll.height = self.viewEduAndExp.frame.origin.y+self.viewEduAndExp.frame.size.height+15;
    [self.scrollCvView setContentSize:sizeScroll];
}

- (float)fillCvEducation:(NSDictionary *)educationData
           contentHeight:(float)contentHeight
{
    if ([self.cvData[0][@"Degree"] isEqualToString:educationData[@"Degree"]]) {
        NSString *strWorkYears = nil;
        if ([self.intentionData[0][@"RelatedWorkYears"] isEqualToString:@"0"]) {
            strWorkYears = @"无工作经验";
        }
        else if ([self.intentionData[0][@"RelatedWorkYears"] isEqualToString:@"11"]) {
            strWorkYears = @"10年以上";
        }
        else {
            strWorkYears = [NSString stringWithFormat:@"%@年",self.intentionData[0][@"RelatedWorkYears"]];
        }
        [self.lbPaOther setText:[NSString stringWithFormat:@"%@ | %@（%@）",strWorkYears,educationData[@"Education"],educationData[@"EduTypeName"]]];
    }
    
    float destinationContentHeight = contentHeight;
    //添加标题
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 40, 20)];
    [lbTitle setText:@"学习"];
    [lbTitle setTextColor:[UIColor whiteColor]];
    [lbTitle setFont:[UIFont systemFontOfSize:10]];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setBackgroundColor:[UIColor colorWithRed:14.f/255.f green:170.f/255.f blue:32.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbTitle];
    [lbTitle release];
    //添加教育背景信息
    UILabel *lbEduDetail = [[UILabel alloc] init];
    [lbEduDetail setText:[NSString stringWithFormat:@"%@毕业 | %@ | %@ | %@（%@）",[NSString stringWithFormat:@"%@年%@月",[educationData[@"Graduation"] substringWithRange:NSMakeRange(0, 4)],[educationData[@"Graduation"] substringWithRange:NSMakeRange(4, 2)]],educationData[@"GraduateCollage"],educationData[@"MajorName"],educationData[@"Education"],educationData[@"EduTypeName"]]];
    
    CGSize labelSize = [CommonController CalculateFrame:lbEduDetail.text fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(245, 500)];
    [lbEduDetail setFrame:CGRectMake(60, destinationContentHeight, 240, labelSize.height)];
    [lbEduDetail setFont:[UIFont systemFontOfSize:12]];
    lbEduDetail.numberOfLines = 0;
    lbEduDetail.lineBreakMode = NSLineBreakByCharWrapping;
    [lbEduDetail setTextAlignment:NSTextAlignmentLeft];
    [self.viewEduAndExp addSubview:lbEduDetail];
    [lbEduDetail release];
    destinationContentHeight += labelSize.height+10;
    //添加学习经历
    if (educationData[@"Details"]) {
        UILabel *lbDetailsTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 60, 15)];
        [lbDetailsTitle setText:@"学习经历:"];
        [lbDetailsTitle setFont:[UIFont systemFontOfSize:12]];
        [self.viewEduAndExp addSubview:lbDetailsTitle];
        [lbDetailsTitle release];
        UILabel *lbDetails = [[UILabel alloc] init];
        [lbDetails setText:educationData[@"Details"]];
        labelSize = [CommonController CalculateFrame:lbDetails.text fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(240, 5000)];
        [lbDetails setFrame:CGRectMake(70, destinationContentHeight, 240, labelSize.height)];
        [lbDetails setFont:[UIFont systemFontOfSize:12]];
        lbDetails.numberOfLines = 0;
        lbDetails.lineBreakMode = NSLineBreakByCharWrapping;
        [self.viewEduAndExp addSubview:lbDetails];
        [lbDetails release];
        destinationContentHeight += labelSize.height+15;
    }
    return destinationContentHeight;
}

- (void)getCvExperience:(NSArray *)arrayCvExperience
{
    float heightViewExperience = self.viewEduAndExp.frame.size.height;
    for (NSDictionary *dicExperience in arrayCvExperience) {
        heightViewExperience = [self fillCvExperience:dicExperience contentHeight:heightViewExperience];
    }
    //修改位置和高度
    CGRect frameViewExperience = self.viewEduAndExp.frame;
    frameViewExperience.size.height = heightViewExperience;
    CGSize sizeScroll = self.scrollCvView.contentSize;
    [self.viewEduAndExp setFrame:frameViewExperience];
    sizeScroll.height = self.viewEduAndExp.frame.origin.y+self.viewEduAndExp.frame.size.height;
    [self.scrollCvView setContentSize:sizeScroll];
}

- (float)fillCvExperience:(NSDictionary *)experienceData
            contentHeight:(float)contentHeight
{
    float destinationContentHeight = contentHeight;
    //添加标题
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 40, 20)];
    [lbTitle setText:@"工作"];
    [lbTitle setTextColor:[UIColor whiteColor]];
    [lbTitle setFont:[UIFont systemFontOfSize:10]];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setBackgroundColor:[UIColor colorWithRed:240.f/255.f green:78.f/255.f blue:44.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbTitle];
    [lbTitle release];
    //添加工作经历信息
    NSString *strEndDate;
    if ([experienceData[@"EndDate"] isEqualToString:@"999999"]) {
        strEndDate = @"至今";
    }
    else {
        strEndDate = [NSString stringWithFormat:@"%@年%@月",[experienceData[@"EndDate"] substringWithRange:NSMakeRange(0, 4)],[experienceData[@"EndDate"] substringWithRange:NSMakeRange(4, 2)]];
    }
    UILabel *lbExpDetail = [[UILabel alloc] init];
    [lbExpDetail setText:[NSString stringWithFormat:@"%@-%@ | %@ | %@（%@）",[NSString stringWithFormat:@"%@年%@月",[experienceData[@"BeginDate"] substringWithRange:NSMakeRange(0, 4)],[experienceData[@"BeginDate"] substringWithRange:NSMakeRange(4, 2)]],strEndDate,experienceData[@"CompanyName"],experienceData[@"JobName"],experienceData[@"LowerNumber"]]];
    
    CGSize labelSize = [CommonController CalculateFrame:lbExpDetail.text fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(245, 500)];
    [lbExpDetail setFrame:CGRectMake(60, destinationContentHeight, 240, labelSize.height)];
    [lbExpDetail setFont:[UIFont systemFontOfSize:12]];
    lbExpDetail.numberOfLines = 0;
    lbExpDetail.lineBreakMode = NSLineBreakByCharWrapping;
    [lbExpDetail setTextAlignment:NSTextAlignmentLeft];
    [self.viewEduAndExp addSubview:lbExpDetail];
    [lbExpDetail release];
    destinationContentHeight += labelSize.height+10;
    
    //添加企业规模
    UILabel *lbCompanySizeTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 60, 15)];
    [lbCompanySizeTitle setText:@"企业规模:"];
    [lbCompanySizeTitle setFont:[UIFont systemFontOfSize:12]];
    [self.viewEduAndExp addSubview:lbCompanySizeTitle];
    [lbCompanySizeTitle release];
    UILabel *lbCompanySize = [[UILabel alloc] init];
    [lbCompanySize setText:experienceData[@"CpmpanySize"]];
    [lbCompanySize setFrame:CGRectMake(70, destinationContentHeight, 240, 15)];
    [lbCompanySize setFont:[UIFont systemFontOfSize:12]];
    lbCompanySize.numberOfLines = 0;
    lbCompanySize.lineBreakMode = NSLineBreakByCharWrapping;
    [self.viewEduAndExp addSubview:lbCompanySize];
    [lbCompanySize release];
    destinationContentHeight += 30;
    
    //添加工作描述
    UILabel *lbDescriptionTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 60, 15)];
    [lbDescriptionTitle setText:@"工作描述:"];
    [lbDescriptionTitle setFont:[UIFont systemFontOfSize:12]];
    [self.viewEduAndExp addSubview:lbDescriptionTitle];
    [lbDescriptionTitle release];
    UILabel *lbDescription = [[UILabel alloc] init];
    [lbDescription setText:experienceData[@"Description"]];
    labelSize = [CommonController CalculateFrame:lbDescription.text fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(240, 5000)];
    [lbDescription setFrame:CGRectMake(70, destinationContentHeight, 240, labelSize.height)];
    [lbDescription setFont:[UIFont systemFontOfSize:12]];
    lbDescription.numberOfLines = 0;
    lbDescription.lineBreakMode = NSLineBreakByCharWrapping;
    [self.viewEduAndExp addSubview:lbDescription];
    [lbDescription release];
    destinationContentHeight += labelSize.height+15;
    return destinationContentHeight;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    
}

- (void)netRequestFinishedFromCvInfo:(NetWebServiceRequest *)request
                          xmlContent:(GDataXMLDocument *)xmlContent
{
    
    self.cvData = [self getArrayFromXml:xmlContent tableName:@"Table1"];
    self.paData = [self getArrayFromXml:xmlContent tableName:@"paData"];
    [self getPaBasic];
    [self getJobIntention:[self getArrayFromXml:xmlContent tableName:@"Table4"]];
    [self getCvSpecaility];
    [self getCvEducation:[self getArrayFromXml:xmlContent tableName:@"Table2"]];
    [self getCvExperience:[self getArrayFromXml:xmlContent tableName:@"Table3"]];
    CGSize scrollSize = [self.scrollCvView contentSize];
    CGRect frameViewLink = self.viewLink.frame;
    frameViewLink.origin.y = scrollSize.height;
    [self.viewLink setFrame:frameViewLink];
    scrollSize.height += frameViewLink.size.height;
    [self.scrollCvView setContentSize:scrollSize];
    [loadView stopAnimating];
}

//获取相关表数据
- (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName
{
    NSArray *xmlTable = [xmlContent nodesForXPath:[NSString stringWithFormat:@"//%@", tableName] error:nil];
    NSMutableArray *arrXml = [[[NSMutableArray alloc] init] autorelease];
    for (int i=0; i<xmlTable.count; i++) {
        GDataXMLElement *oneXmlElement = [xmlTable objectAtIndex:i];
        NSArray *arrChild = [oneXmlElement children];
        NSMutableDictionary *dicOneXml = [[NSMutableDictionary alloc] init];
        for (int j=0; j<arrChild.count; j++) {
            [dicOneXml setObject:[arrChild[j] stringValue] forKey:[arrChild[j] name]];
        }
        [arrXml addObject:dicOneXml];
        [dicOneXml release];
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
    [_cPopup release];
    [_userDefaults release];
    [_cvData release];
    [_paData release];
    [_intentionData release];
    [_lbPaName release];
    [_lbGender release];
    [_lbBirth release];
    [_lbLivePlace release];
    [_lbAccountPlace release];
    [_lbGrowPlace release];
    [_lbMobile release];
    [_lbEmail release];
    [_scrollCvView release];
    [_viewJobIntention release];
    [_lbEmployType release];
    [_lbSalary release];
    [_lbExpectJobPlace release];
    [_lbExpectJobType release];
    [_lbSpeciality release];
    [_viewSpeciality release];
    [_lbPaOther release];
    [_lbLoginDate release];
    [_lbRefreshDate release];
    [_imgPhoto release];
    [_viewIntention1 release];
    [_viewIntention2 release];
    [_viewEduAndExp release];
    [_imgMobileCer release];
    [_lbMobileCer release];
    [_viewPaBasic release];
    [_viewLink release];
    [_lbMobile2 release];
    [_lbEmail2 release];
    [super dealloc];
}
@end