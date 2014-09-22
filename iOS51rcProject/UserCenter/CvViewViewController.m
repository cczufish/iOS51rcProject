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
    CGSize lableSize = [CommonController CalculateFrame:self.lbPaName.text fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(800, 15)];
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
    [self.lbMobile setText:self.paData[0][@"Mobile"]];
    [self.lbEmail setText:self.paData[0][@"Email"]];
    
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
    [self.viewSpeciality setBackgroundColor:[UIColor redColor]];
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
    [self.viewEduAndExp setBackgroundColor:[UIColor grayColor]];
    sizeScroll.height = self.viewEduAndExp.frame.origin.y+self.viewEduAndExp.frame.size.height+15;
    [self.scrollCvView setContentSize:sizeScroll];
}

- (float)fillCvEducation:(NSDictionary *)educationData
           contentHeight:(float)contentHeight
{
    float destinationContentHeight = contentHeight;
    //添加分割线的球形
    UIImageView *imgSeparate = [[UIImageView alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 16, 16)];
    [imgSeparate setImage:[UIImage imageNamed:@"ico_cvmain_group.png"]];
    [self.viewEduAndExp addSubview:imgSeparate];
    [imgSeparate release];
    
    //添加分割线
    CGRect frameSeparate = CGRectMake(22, destinationContentHeight+16, 1, 1);
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:frameSeparate];
    [lbSeparate setBackgroundColor:[UIColor colorWithRed:87.f/255.f green:212.f/255.f blue:117.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbSeparate];
    
    //毕业学校
    UILabel *lbCollegeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbCollegeTitle setFont:[UIFont systemFontOfSize:12]];
    [lbCollegeTitle setTextAlignment:NSTextAlignmentRight];
    [lbCollegeTitle setText:@"毕业学校"];
    [lbCollegeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbCollege = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbCollege setFont:[UIFont systemFontOfSize:12]];
    [lbCollege setTextAlignment:NSTextAlignmentLeft];
    [lbCollege setText:educationData[@"GraduateCollage"]];
    [lbCollege setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbCollegeTitle];
    [self.viewEduAndExp addSubview:lbCollege];
    [lbCollege release];
    [lbCollegeTitle release];
    destinationContentHeight += 27;
    
    //毕业时间
    UILabel *lbGraduationDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbGraduationDateTitle setFont:[UIFont systemFontOfSize:12]];
    [lbGraduationDateTitle setTextAlignment:NSTextAlignmentRight];
    [lbGraduationDateTitle setText:@"毕业时间"];
    [lbGraduationDateTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbGraduationDate = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbGraduationDate setFont:[UIFont systemFontOfSize:12]];
    [lbGraduationDate setTextAlignment:NSTextAlignmentLeft];
    [lbGraduationDate setText:[NSString stringWithFormat:@"%@年%@月",[educationData[@"Graduation"] substringWithRange:NSMakeRange(0, 4)],[educationData[@"Graduation"] substringWithRange:NSMakeRange(4, 2)]]];
    [lbGraduationDate setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbGraduationDateTitle];
    [self.viewEduAndExp addSubview:lbGraduationDate];
    [lbGraduationDate release];
    [lbGraduationDateTitle release];
    destinationContentHeight += 27;
    
    //学历
    UILabel *lbDegreeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbDegreeTitle setFont:[UIFont systemFontOfSize:12]];
    [lbDegreeTitle setTextAlignment:NSTextAlignmentRight];
    [lbDegreeTitle setText:@"学历"];
    [lbDegreeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbDegree = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbDegree setFont:[UIFont systemFontOfSize:12]];
    [lbDegree setTextAlignment:NSTextAlignmentLeft];
    [lbDegree setText:educationData[@"Education"]];
    [lbDegree setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbDegreeTitle];
    [self.viewEduAndExp addSubview:lbDegree];
    [lbDegree release];
    [lbDegreeTitle release];
    destinationContentHeight += 27;
    
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
    
    //学历类型
    UILabel *lbEducationTypeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbEducationTypeTitle setFont:[UIFont systemFontOfSize:12]];
    [lbEducationTypeTitle setTextAlignment:NSTextAlignmentRight];
    [lbEducationTypeTitle setText:@"学历类型"];
    [lbEducationTypeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbEducationType = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbEducationType setFont:[UIFont systemFontOfSize:12]];
    [lbEducationType setTextAlignment:NSTextAlignmentLeft];
    [lbEducationType setText:educationData[@"EduTypeName"]];
    [lbEducationType setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbEducationTypeTitle];
    [self.viewEduAndExp addSubview:lbEducationType];
    [lbEducationType release];
    [lbEducationTypeTitle release];
    destinationContentHeight += 27;
    
    //专业
    UILabel *lbMajorTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbMajorTitle setFont:[UIFont systemFontOfSize:12]];
    [lbMajorTitle setTextAlignment:NSTextAlignmentRight];
    [lbMajorTitle setText:@"专业"];
    [lbMajorTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbMajor = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbMajor setFont:[UIFont systemFontOfSize:12]];
    [lbMajor setTextAlignment:NSTextAlignmentLeft];
    [lbMajor setText:educationData[@"Major"]];
    [lbMajor setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbMajorTitle];
    [self.viewEduAndExp addSubview:lbMajor];
    [lbMajor release];
    [lbMajorTitle release];
    destinationContentHeight += 27;
    
    //专业名称
    UILabel *lbMajorNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbMajorNameTitle setFont:[UIFont systemFontOfSize:12]];
    [lbMajorNameTitle setTextAlignment:NSTextAlignmentRight];
    [lbMajorNameTitle setText:@"专业名称"];
    [lbMajorNameTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbMajorName = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbMajorName setFont:[UIFont systemFontOfSize:12]];
    [lbMajorName setTextAlignment:NSTextAlignmentLeft];
    [lbMajorName setText:educationData[@"MajorName"]];
    [lbMajorName setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbMajorNameTitle];
    [self.viewEduAndExp addSubview:lbMajorName];
    [lbMajorName release];
    [lbMajorNameTitle release];
    destinationContentHeight += 27;
    
    //学习经历
    UILabel *lbDetailsTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbDetailsTitle setFont:[UIFont systemFontOfSize:12]];
    [lbDetailsTitle setTextAlignment:NSTextAlignmentRight];
    [lbDetailsTitle setText:@"学习经历"];
    [lbDetailsTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbDetails = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbDetails setFont:[UIFont systemFontOfSize:12]];
    [lbDetails setTextAlignment:NSTextAlignmentLeft];
    [lbDetails setText:educationData[@"Details"]];
    CGSize labelSize = [CommonController CalculateFrame:educationData[@"Details"] fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(160, 5000)];
    if (labelSize.height > 20) {
        //重设学历经历的高度
        lbDetails.lineBreakMode = NSLineBreakByCharWrapping;
        lbDetails.numberOfLines = 0;
        CGRect frameDetails = lbDetails.frame;
        frameDetails.size.height = labelSize.height;
        [lbDetails setFrame:frameDetails];
        destinationContentHeight += labelSize.height-15;
    }
    else {
        //重设学历经历的高度
        CGRect frameDetails = lbDetails.frame;
        frameDetails.size.height = 15;
        [lbDetails setFrame:frameDetails];
    }
    [lbDetails setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbDetailsTitle];
    [self.viewEduAndExp addSubview:lbDetails];
    [lbDetails release];
    [lbDetailsTitle release];
    
    frameSeparate.size.height = destinationContentHeight-contentHeight;
    [lbSeparate setFrame:frameSeparate];
    [lbSeparate release];
    
    destinationContentHeight += 35;
    return destinationContentHeight;
}

- (void)getCvExperience:(NSArray *)arrayCvExperience
{
    float heightViewExperience = 65;
    for (NSDictionary *dicExperience in arrayCvExperience) {
        heightViewExperience = [self fillCvExperience:dicExperience contentHeight:heightViewExperience];
    }
    //修改位置和高度
    CGRect frameViewExperience = self.viewEduAndExp.frame;
    frameViewExperience.size.height = heightViewExperience;
    CGSize sizeScroll = self.scrollCvView.contentSize;
    frameViewExperience.origin.y = sizeScroll.height;
    [self.viewEduAndExp setFrame:frameViewExperience];
    sizeScroll.height = self.viewEduAndExp.frame.origin.y+self.viewEduAndExp.frame.size.height+15;
    [self.scrollCvView setContentSize:sizeScroll];
}

- (float)fillCvExperience:(NSDictionary *)experienceData
            contentHeight:(float)contentHeight
{
    float destinationContentHeight = contentHeight;
    //添加分割线的球形
    UIImageView *imgSeparate = [[UIImageView alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 16, 16)];
    [imgSeparate setImage:[UIImage imageNamed:@"ico_cvmain_group.png"]];
    [self.viewEduAndExp addSubview:imgSeparate];
    [imgSeparate release];
    
    //添加分割线
    CGRect frameSeparate = CGRectMake(22, destinationContentHeight+16, 1, 1);
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:frameSeparate];
    [lbSeparate setBackgroundColor:[UIColor colorWithRed:87.f/255.f green:212.f/255.f blue:117.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbSeparate];
    
    //公司名称
    UILabel *lbCompanyTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbCompanyTitle setFont:[UIFont systemFontOfSize:12]];
    [lbCompanyTitle setTextAlignment:NSTextAlignmentRight];
    [lbCompanyTitle setText:@"公司名称"];
    [lbCompanyTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbCompany = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbCompany setFont:[UIFont systemFontOfSize:12]];
    [lbCompany setTextAlignment:NSTextAlignmentLeft];
    [lbCompany setText:experienceData[@"CompanyName"]];
    [lbCompany setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbCompanyTitle];
    [self.viewEduAndExp addSubview:lbCompany];
    [lbCompany release];
    [lbCompanyTitle release];
    destinationContentHeight += 27;
    
    //所属行业
    UILabel *lbIndustryTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbIndustryTitle setFont:[UIFont systemFontOfSize:12]];
    [lbIndustryTitle setTextAlignment:NSTextAlignmentRight];
    [lbIndustryTitle setText:@"所属行业"];
    [lbIndustryTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbIndustry = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbIndustry setFont:[UIFont systemFontOfSize:12]];
    [lbIndustry setTextAlignment:NSTextAlignmentLeft];
    [lbIndustry setText:experienceData[@"Industry"]];
    [lbIndustry setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbIndustryTitle];
    [self.viewEduAndExp addSubview:lbIndustry];
    [lbIndustry release];
    [lbIndustryTitle release];
    destinationContentHeight += 27;
    
    //公司规模
    UILabel *lbCompanySizeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbCompanySizeTitle setFont:[UIFont systemFontOfSize:12]];
    [lbCompanySizeTitle setTextAlignment:NSTextAlignmentRight];
    [lbCompanySizeTitle setText:@"公司规模"];
    [lbCompanySizeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbCompanySize = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbCompanySize setFont:[UIFont systemFontOfSize:12]];
    [lbCompanySize setTextAlignment:NSTextAlignmentLeft];
    [lbCompanySize setText:experienceData[@"CpmpanySize"]];
    [lbCompanySize setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbCompanySizeTitle];
    [self.viewEduAndExp addSubview:lbCompanySize];
    [lbCompanySize release];
    [lbCompanySizeTitle release];
    destinationContentHeight += 27;
    
    //职位名称
    UILabel *lbJobNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbJobNameTitle setFont:[UIFont systemFontOfSize:12]];
    [lbJobNameTitle setTextAlignment:NSTextAlignmentRight];
    [lbJobNameTitle setText:@"职位名称"];
    [lbJobNameTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbJobName setFont:[UIFont systemFontOfSize:12]];
    [lbJobName setTextAlignment:NSTextAlignmentLeft];
    [lbJobName setText:experienceData[@"JobName"]];
    [lbJobName setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbJobNameTitle];
    [self.viewEduAndExp addSubview:lbJobName];
    [lbJobName release];
    [lbJobNameTitle release];
    destinationContentHeight += 27;
    
    //职位类别
    UILabel *lbJobTypeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbJobTypeTitle setFont:[UIFont systemFontOfSize:12]];
    [lbJobTypeTitle setTextAlignment:NSTextAlignmentRight];
    [lbJobTypeTitle setText:@"职位类别"];
    [lbJobTypeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbJobType = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbJobType setFont:[UIFont systemFontOfSize:12]];
    [lbJobType setTextAlignment:NSTextAlignmentLeft];
    [lbJobType setText:experienceData[@"JobType"]];
    [lbJobType setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbJobTypeTitle];
    [self.viewEduAndExp addSubview:lbJobType];
    [lbJobType release];
    [lbJobTypeTitle release];
    destinationContentHeight += 27;
    
    //开始时间
    UILabel *lbBeginDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbBeginDateTitle setFont:[UIFont systemFontOfSize:12]];
    [lbBeginDateTitle setTextAlignment:NSTextAlignmentRight];
    [lbBeginDateTitle setText:@"开始时间"];
    [lbBeginDateTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbBeginDate = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbBeginDate setFont:[UIFont systemFontOfSize:12]];
    [lbBeginDate setTextAlignment:NSTextAlignmentLeft];
    [lbBeginDate setText:[NSString stringWithFormat:@"%@年%@月",[experienceData[@"BeginDate"] substringWithRange:NSMakeRange(0, 4)],[experienceData[@"BeginDate"] substringWithRange:NSMakeRange(4, 2)]]];
    [lbBeginDate setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbBeginDateTitle];
    [self.viewEduAndExp addSubview:lbBeginDate];
    [lbBeginDate release];
    [lbBeginDateTitle release];
    destinationContentHeight += 27;
    
    //结束时间
    UILabel *lbEndDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbEndDateTitle setFont:[UIFont systemFontOfSize:12]];
    [lbEndDateTitle setTextAlignment:NSTextAlignmentRight];
    [lbEndDateTitle setText:@"结束时间"];
    [lbEndDateTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbEndDate = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbEndDate setFont:[UIFont systemFontOfSize:12]];
    [lbEndDate setTextAlignment:NSTextAlignmentLeft];
    if ([experienceData[@"EndDate"] isEqualToString:@"999999"]) {
        [lbEndDate setText:@"至今"];
    }
    else {
        [lbEndDate setText:[NSString stringWithFormat:@"%@年%@月",[experienceData[@"EndDate"] substringWithRange:NSMakeRange(0, 4)],[experienceData[@"EndDate"] substringWithRange:NSMakeRange(4, 2)]]];
    }
    [lbEndDate setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbEndDateTitle];
    [self.viewEduAndExp addSubview:lbEndDate];
    [lbEndDate release];
    [lbEndDateTitle release];
    destinationContentHeight += 27;
    
    //下属人数
    UILabel *lbLowerNumberTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbLowerNumberTitle setFont:[UIFont systemFontOfSize:12]];
    [lbLowerNumberTitle setTextAlignment:NSTextAlignmentRight];
    [lbLowerNumberTitle setText:@"下属人数"];
    [lbLowerNumberTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbLowerNumber = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbLowerNumber setFont:[UIFont systemFontOfSize:12]];
    [lbLowerNumber setTextAlignment:NSTextAlignmentLeft];
    [lbLowerNumber setText:experienceData[@"LowerNumber"]];
    [lbLowerNumber setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbLowerNumberTitle];
    [self.viewEduAndExp addSubview:lbLowerNumber];
    [lbLowerNumber release];
    [lbLowerNumberTitle release];
    destinationContentHeight += 27;
    
    //工作描述
    UILabel *lbDescriptionTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbDescriptionTitle setFont:[UIFont systemFontOfSize:12]];
    [lbDescriptionTitle setTextAlignment:NSTextAlignmentRight];
    [lbDescriptionTitle setText:@"工作描述"];
    [lbDescriptionTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbDescription setFont:[UIFont systemFontOfSize:12]];
    [lbDescription setTextAlignment:NSTextAlignmentLeft];
    [lbDescription setText:experienceData[@"Description"]];
    CGSize labelSize = [CommonController CalculateFrame:experienceData[@"Description"] fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(160, 5000)];
    if (labelSize.height > 20) {
        //重设工作描述的高度
        CGRect frameDescription = lbDescription.frame;
        lbDescription.lineBreakMode = NSLineBreakByCharWrapping;
        lbDescription.numberOfLines = 0;
        frameDescription.size.height = labelSize.height;
        [lbDescription setFrame:frameDescription];
        destinationContentHeight += labelSize.height-15;
    }
    else {
        //重设工作描述的高度
        CGRect frameDescription = lbDescription.frame;
        frameDescription.size.height = 15;
        [lbDescription setFrame:frameDescription];
    }
    [lbDescription setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEduAndExp addSubview:lbDescriptionTitle];
    [self.viewEduAndExp addSubview:lbDescription];
    [lbDescription release];
    [lbDescriptionTitle release];
    
    frameSeparate.size.height = destinationContentHeight-contentHeight;
    [lbSeparate setFrame:frameSeparate];
    [lbSeparate release];
    
    destinationContentHeight += 35;
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
//    [self getCvExperience:[self getArrayFromXml:xmlContent tableName:@"Table3"]];
    [loadView stopAnimating];
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
    [super dealloc];
}
@end