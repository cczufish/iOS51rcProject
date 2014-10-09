//
//  CvModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-15.
//

#import "CvModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "CustomPopup.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "CommonController.h"
#import "PaModifyViewController.h"
#import "IntentionModifyViewController.h"
#import "EducationModifyViewController.h"
#import "ExperienceModifyViewController.h"
#import "SpecialitityModifyViewController.h"
#import "MyCvViewController.h"
#import "SlideNavigationController.h"

@interface CvModifyViewController ()<NetWebServiceRequestDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MLImageCropDelegate>
{
    LoadingAnimationView *loadView;
    float fltHeight;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSArray *cvData;
@property (nonatomic, retain) NSArray *paData;
@property (nonatomic, retain) CustomPopup *cPopup;

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
    [self.navigationItem setTitle:@"简历修改"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [loadView startAnimating];
    
    //添加边框
    self.btnCvName.layer.cornerRadius = 5;
    self.btnCvName.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnCvName.layer.borderWidth = 1;
    self.viewPaInfo.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.viewPaInfo.layer.borderWidth = 0.5;
    self.viewJobIntention.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.viewJobIntention.layer.borderWidth = 0.5;
    self.viewSpeciality.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.viewSpeciality.layer.borderWidth = 0.5;
    self.viewEducation.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.viewEducation.layer.borderWidth = 0.5;
    self.viewExperience.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.viewExperience.layer.borderWidth = 0.5;
    self.btnPhotoCancel.layer.cornerRadius = 5;
    self.btnConfirmOK.layer.cornerRadius = 5;
    self.btnConfirmCancel.layer.cornerRadius = 5;
    
    //获取数据
    [self getCvInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2] isMemberOfClass:[MyCvViewController class]]) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(gotoMyCv)];
        [self.navigationItem setLeftBarButtonItem:backItem];
        [backItem release];
    }
    if (self.toastType > 0) {
        //获取数据
        [self getCvInfo];
    }
    //返回该view后显示相关的toast
    if (self.toastType == 1) {
        [self.view makeToast:@"基本信息保存成功"];
    }
    else if (self.toastType == 2)
    {
        [self.view makeToast:@"求职意向保存成功"];
    }
    else if (self.toastType == 3)
    {
        [self.view makeToast:@"教育背景保存成功"];
    }
    else if (self.toastType == 4)
    {
        [self.view makeToast:@"工作经历保存成功"];
    }
    else if (self.toastType == 5)
    {
        [self.view makeToast:@"工作能力保存成功"];
    }
    self.toastType = 0;
}

- (void)gotoMyCv
{
    MyCvViewController *myCvViewC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCvView"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:myCvViewC withSlideOutAnimation:true andCompletion:nil];
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

- (void)getCvBasic
{
    [self.lbCvName setText:self.cvData[0][@"Name"]];
    [self.txtCvName setText:self.cvData[0][@"Name"]];
    [self.lbCvScore setText:[NSString stringWithFormat:@"%d分",[self getCvLevelScore:self.cvData[0][@"cvLevel"] hasPhoto:self.paData[0][@"HasPhoto"]]]];
}

- (void)getPaBasic
{
    [self.lbEmail setText:self.paData[0][@"Email"]];
    if (!self.paData[0][@"LivePlace"]) {
        return;
    }
    [self.lbPaName setText:self.paData[0][@"Name"]];
    [self.lbLivePlace setText:self.paData[0][@"LiveRegion"]];
    [self.lbAccountPlace setText:self.paData[0][@"AccountRegion"]];
    [self.lbGrowPlace setText:self.paData[0][@"GrowRegion"]];
    [self.lbMobile setText:self.paData[0][@"Mobile"]];
    [self.lbBirth setText:[NSString stringWithFormat:@"%@年%@月",[self.paData[0][@"BirthDay"] substringWithRange:NSMakeRange(0, 4)],[self.paData[0][@"BirthDay"] substringWithRange:NSMakeRange(4, 2)]]];
    if ([self.paData[0][@"Gender"] isEqualToString:@"false"]) {
        [self.lbGender setText:@"男"];
    }
    else {
        [self.lbGender setText:@"女"];
    }
    if (self.paData[0][@"PhotoProcessed"])
    {
        if (![self.paData[0][@"HasPhoto"] isEqualToString:@"2"]) {
            NSString *path = [NSString stringWithFormat:@"%d",([[self.userDefaults objectForKey:@"UserID"] intValue] / 100000 + 1) * 100000];
            for (int i=0; i<9-path.length; i++) {
                path = [NSString stringWithFormat:@"0%@",path];
            }
            path = [NSString stringWithFormat:@"L%@",path];
            path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Photo/%@/Processed/%@",path,self.paData[0][@"PhotoProcessed"]];
            [self.btnPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]] forState:UIControlStateNormal];
        }
    }
}

- (void)getJobIntention:(NSArray *)arrayCvIntention
{
    CGRect frameViewJobIntention = self.viewJobIntention.frame;
    frameViewJobIntention.size.height = 205;
    if (arrayCvIntention[0][@"RelatedWorkYears"]) {
        [self.lbEmployType setText:[CommonController getDictionaryDesc:arrayCvIntention[0][@"EmployType"] tableName:@"EmployType"]];
        if ([arrayCvIntention[0][@"IsNegotiable"] isEqualToString:@"true"]) {
            [self.lbSalary setText:[NSString stringWithFormat:@"%@（可面议）",arrayCvIntention[0][@"Salary"]]];
        }
        else {
            [self.lbSalary setText:arrayCvIntention[0][@"Salary"]];
        }
        if ([arrayCvIntention[0][@"RelatedWorkYears"] isEqualToString:@"0"]) {
            [self.lbExperience setText:@"无"];
        }
        else if ([arrayCvIntention[0][@"RelatedWorkYears"] isEqualToString:@"11"]) {
            [self.lbExperience setText:@"10年以上"];
        }
        else {
            [self.lbExperience setText:[NSString stringWithFormat:@"%@年",arrayCvIntention[0][@"RelatedWorkYears"]]];
        }
        CGSize labelSize = [CommonController CalculateFrame:arrayCvIntention[0][@"JobPlaceName"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(160, 300)];
        [self.lbExpectJobPlace setText:arrayCvIntention[0][@"JobPlaceName"]];
        [self.lbExpectJobType setText:arrayCvIntention[0][@"JobTypeName"]];
        if (labelSize.height > 20) {
            //期望职位类别多行，将下面的控件位置处理
            CGRect frameExpectJobPlace = self.lbExpectJobPlace.frame;
            frameExpectJobPlace.size.height = labelSize.height;
            [self.lbExpectJobPlace setFrame:frameExpectJobPlace];
            
            CGRect frameExpectJobType = self.lbExpectJobType.frame;
            frameExpectJobType.origin.y = frameExpectJobPlace.origin.y + frameExpectJobPlace.size.height + 12;
            [self.lbExpectJobType setFrame:frameExpectJobType];
            
            CGRect frameExpectJobTypeTitle = self.lbExpectJobTypeTitle.frame;
            frameExpectJobTypeTitle.origin.y = frameExpectJobPlace.origin.y + frameExpectJobPlace.size.height + 12;
            [self.lbExpectJobTypeTitle setFrame:frameExpectJobTypeTitle];
            //修改求职意向view的高度
            frameViewJobIntention.size.height += labelSize.height-15;
        }
        else {
            //期望职位类别多行，将下面的控件位置处理
            CGRect frameExpectJobPlace = self.lbExpectJobPlace.frame;
            frameExpectJobPlace.size.height = 15;
            [self.lbExpectJobPlace setFrame:frameExpectJobPlace];
            
            CGRect frameExpectJobType = self.lbExpectJobType.frame;
            frameExpectJobType.origin.y = 173;
            [self.lbExpectJobType setFrame:frameExpectJobType];
            
            CGRect frameExpectJobTypeTitle = self.lbExpectJobTypeTitle.frame;
            frameExpectJobTypeTitle.origin.y = 173;
            [self.lbExpectJobTypeTitle setFrame:frameExpectJobTypeTitle];
        }
        labelSize = [CommonController CalculateFrame:arrayCvIntention[0][@"JobTypeName"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(160, 300)];
        if (labelSize.height > 20) {
            CGRect frameExpectJobType = self.lbExpectJobType.frame;
            frameExpectJobType.size.height = labelSize.height;
            [self.lbExpectJobType setFrame:frameExpectJobType];
            //修改求职意向view的高度
            frameViewJobIntention.size.height += labelSize.height-15;
        }
        else {
            CGRect frameExpectJobType = self.lbExpectJobType.frame;
            frameExpectJobType.size.height = 15;
            [self.lbExpectJobType setFrame:frameExpectJobType];
        }
    }
    [self.viewJobIntention setFrame:frameViewJobIntention];
    [self.scrollCvModify setContentSize:CGSizeMake(320, self.viewJobIntention.frame.origin.y+self.viewJobIntention.frame.size.height+15)];
}

- (void)getCvEducation:(NSArray *)arrayCvEducation
{
    NSArray *arrayViews = self.viewEducation.subviews;
    for (int i=0; i<arrayViews.count; i++) {
        if (i>0) {
            [arrayViews[i] removeFromSuperview];
        }
    }
    if (arrayCvEducation.count > 19) {
        [self.btnAddEducation setHidden:true];
    }
    else {
        [self.btnAddEducation setHidden:false];
    }
    float heightViewEducation = 65;
    for (NSDictionary *dicEducation in arrayCvEducation) {
        heightViewEducation = [self fillCvEducation:dicEducation contentHeight:heightViewEducation educationCount:arrayCvEducation.count];
    }
    //修改位置和高度
    CGRect frameViewEducation = self.viewEducation.frame;
    frameViewEducation.size.height = heightViewEducation;
    CGSize sizeScroll = self.scrollCvModify.contentSize;
    frameViewEducation.origin.y = sizeScroll.height;
    [self.viewEducation setFrame:frameViewEducation];
    sizeScroll.height = self.viewEducation.frame.origin.y+self.viewEducation.frame.size.height+15;
    [self.scrollCvModify setContentSize:sizeScroll];
}

- (float)fillCvEducation:(NSDictionary *)educationData
                contentHeight:(float)contentHeight
          educationCount:(int)educationCount
{
    float destinationContentHeight = contentHeight;
    //添加分割线的球形
    UIImageView *imgSeparate = [[UIImageView alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 16, 16)];
    [imgSeparate setImage:[UIImage imageNamed:@"ico_cvmain_group.png"]];
    [self.viewEducation addSubview:imgSeparate];
    [imgSeparate release];
    
    //添加分割线
    CGRect frameSeparate = CGRectMake(22, destinationContentHeight+16, 1, 1);
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:frameSeparate];
    [lbSeparate setBackgroundColor:[UIColor colorWithRed:87.f/255.f green:212.f/255.f blue:117.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbSeparate];
    
    //毕业学校
    UILabel *lbCollegeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbCollegeTitle setFont:[UIFont systemFontOfSize:14]];
    [lbCollegeTitle setTextAlignment:NSTextAlignmentRight];
    [lbCollegeTitle setText:@"毕业学校"];
    [lbCollegeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbCollege = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbCollege setFont:[UIFont systemFontOfSize:14]];
    [lbCollege setTextAlignment:NSTextAlignmentLeft];
    [lbCollege setText:educationData[@"GraduateCollage"]];
    [lbCollege setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbCollegeTitle];
    [self.viewEducation addSubview:lbCollege];
    [lbCollege release];
    [lbCollegeTitle release];
    destinationContentHeight += 27;
    
    //毕业时间
    UILabel *lbGraduationDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbGraduationDateTitle setFont:[UIFont systemFontOfSize:14]];
    [lbGraduationDateTitle setTextAlignment:NSTextAlignmentRight];
    [lbGraduationDateTitle setText:@"毕业时间"];
    [lbGraduationDateTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbGraduationDate = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbGraduationDate setFont:[UIFont systemFontOfSize:14]];
    [lbGraduationDate setTextAlignment:NSTextAlignmentLeft];
    [lbGraduationDate setText:[NSString stringWithFormat:@"%@年%@月",[educationData[@"Graduation"] substringWithRange:NSMakeRange(0, 4)],[educationData[@"Graduation"] substringWithRange:NSMakeRange(4, 2)]]];
    [lbGraduationDate setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbGraduationDateTitle];
    [self.viewEducation addSubview:lbGraduationDate];
    [lbGraduationDate release];
    [lbGraduationDateTitle release];
    
    //添加编辑、删除按钮
    UIButton *btnEducationModify = [[UIButton alloc] initWithFrame:CGRectMake(270, destinationContentHeight, 30, 30)];
    [btnEducationModify setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
    [btnEducationModify setTitle:@"编辑" forState:UIControlStateNormal];
    [btnEducationModify.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btnEducationModify.titleLabel setTextColor:[UIColor whiteColor]];
    [btnEducationModify setTag:[educationData[@"ID"] intValue]];
    btnEducationModify.layer.cornerRadius = 5;
    [btnEducationModify addTarget:self action:@selector(switchToEducationModify:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewEducation addSubview:btnEducationModify];
    [btnEducationModify release];
    
    if (educationCount > 1) {
        UIButton *btnEducationDelete = [[UIButton alloc] initWithFrame:CGRectMake(270, destinationContentHeight+35, 30, 30)];
        [btnEducationDelete setImage:[UIImage imageNamed:@"ico_cvmain_del.png"] forState:UIControlStateNormal];
        btnEducationDelete.layer.cornerRadius = 5;
        btnEducationDelete.layer.masksToBounds = YES;
        [btnEducationDelete setTag:[educationData[@"ID"] intValue]];
        [btnEducationDelete addTarget:self action:@selector(deleteCvEducation:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewEducation addSubview:btnEducationDelete];
        [btnEducationDelete release];
    }
    
    destinationContentHeight += 27;
    
    //学历
    UILabel *lbDegreeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbDegreeTitle setFont:[UIFont systemFontOfSize:14]];
    [lbDegreeTitle setTextAlignment:NSTextAlignmentRight];
    [lbDegreeTitle setText:@"学历"];
    [lbDegreeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbDegree = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbDegree setFont:[UIFont systemFontOfSize:14]];
    [lbDegree setTextAlignment:NSTextAlignmentLeft];
    [lbDegree setText:educationData[@"Education"]];
    [lbDegree setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbDegreeTitle];
    [self.viewEducation addSubview:lbDegree];
    [lbDegree release];
    [lbDegreeTitle release];
    destinationContentHeight += 27;
    
    //学历类型
    UILabel *lbEducationTypeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbEducationTypeTitle setFont:[UIFont systemFontOfSize:14]];
    [lbEducationTypeTitle setTextAlignment:NSTextAlignmentRight];
    [lbEducationTypeTitle setText:@"学历类型"];
    [lbEducationTypeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbEducationType = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbEducationType setFont:[UIFont systemFontOfSize:14]];
    [lbEducationType setTextAlignment:NSTextAlignmentLeft];
    [lbEducationType setText:educationData[@"EduTypeName"]];
    [lbEducationType setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbEducationTypeTitle];
    [self.viewEducation addSubview:lbEducationType];
    [lbEducationType release];
    [lbEducationTypeTitle release];
    destinationContentHeight += 27;
    
    //专业
    UILabel *lbMajorTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbMajorTitle setFont:[UIFont systemFontOfSize:14]];
    [lbMajorTitle setTextAlignment:NSTextAlignmentRight];
    [lbMajorTitle setText:@"专业"];
    [lbMajorTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbMajor = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbMajor setFont:[UIFont systemFontOfSize:14]];
    [lbMajor setTextAlignment:NSTextAlignmentLeft];
    [lbMajor setText:educationData[@"Major"]];
    [lbMajor setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbMajorTitle];
    [self.viewEducation addSubview:lbMajor];
    [lbMajor release];
    [lbMajorTitle release];
    destinationContentHeight += 27;
    
    //专业名称
    UILabel *lbMajorNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbMajorNameTitle setFont:[UIFont systemFontOfSize:14]];
    [lbMajorNameTitle setTextAlignment:NSTextAlignmentRight];
    [lbMajorNameTitle setText:@"专业名称"];
    [lbMajorNameTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbMajorName = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbMajorName setFont:[UIFont systemFontOfSize:14]];
    [lbMajorName setTextAlignment:NSTextAlignmentLeft];
    [lbMajorName setText:educationData[@"MajorName"]];
    [lbMajorName setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbMajorNameTitle];
    [self.viewEducation addSubview:lbMajorName];
    [lbMajorName release];
    [lbMajorNameTitle release];
    destinationContentHeight += 27;
    
    //学习经历
    UILabel *lbDetailsTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbDetailsTitle setFont:[UIFont systemFontOfSize:14]];
    [lbDetailsTitle setTextAlignment:NSTextAlignmentRight];
    [lbDetailsTitle setText:@"学习经历"];
    [lbDetailsTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbDetails = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbDetails setFont:[UIFont systemFontOfSize:14]];
    [lbDetails setTextAlignment:NSTextAlignmentLeft];
    [lbDetails setText:educationData[@"Details"]];
    CGSize labelSize = [CommonController CalculateFrame:educationData[@"Details"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(160, 5000)];
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
    [self.viewEducation addSubview:lbDetailsTitle];
    [self.viewEducation addSubview:lbDetails];
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
    NSArray *arrayViews = self.viewExperience.subviews;
    for (int i=0; i<arrayViews.count; i++) {
        if (i>0) {
            [arrayViews[i] removeFromSuperview];
        }
    }
    if (arrayCvExperience.count > 19 || [self.cvData[0][@"cvType"] isEqualToString:@"1"]) {
        [self.btnAddExperience setHidden:true];
    }
    else {
        [self.btnAddExperience setHidden:false];
    }
    float heightViewExperience = 65;
    if (arrayCvExperience.count == 0) {
        [self.viewSetExperience setHidden:false];
        heightViewExperience = 150;
    }
    else {
        [self.viewSetExperience setHidden:true];
        for (NSDictionary *dicExperience in arrayCvExperience) {
            heightViewExperience = [self fillCvExperience:dicExperience contentHeight:heightViewExperience];
        }
    }
    if ([self.cvData[0][@"cvType"] isEqualToString:@"0"]) {
        [self.btnSetHasExp setBackgroundImage:[UIImage imageNamed:@"radio_sel.png"] forState:UIControlStateNormal];
        [self.btnSetHasExp setEnabled:false];
        [self.btnSetNoExp setBackgroundImage:[UIImage imageNamed:@"radio_unsel.png"] forState:UIControlStateNormal];
        [self.btnSetNoExp setEnabled:true];
        [self.btnAddExperience setHidden:false];
    }
    else {
        [self.btnSetHasExp setBackgroundImage:[UIImage imageNamed:@"radio_unsel.png"] forState:UIControlStateNormal];
        [self.btnSetHasExp setEnabled:true];
        [self.btnSetNoExp setBackgroundImage:[UIImage imageNamed:@"radio_sel.png"] forState:UIControlStateNormal];
        [self.btnSetNoExp setEnabled:false];
        [self.btnAddExperience setHidden:true];
    }
    //修改位置和高度
    CGRect frameViewExperience = self.viewExperience.frame;
    frameViewExperience.size.height = heightViewExperience;
    CGSize sizeScroll = self.scrollCvModify.contentSize;
    frameViewExperience.origin.y = sizeScroll.height;
    [self.viewExperience setFrame:frameViewExperience];
    sizeScroll.height = self.viewExperience.frame.origin.y+self.viewExperience.frame.size.height+15;
    [self.scrollCvModify setContentSize:sizeScroll];
}

- (float)fillCvExperience:(NSDictionary *)experienceData
           contentHeight:(float)contentHeight
{
    float destinationContentHeight = contentHeight;
    //添加分割线的球形
    UIImageView *imgSeparate = [[UIImageView alloc] initWithFrame:CGRectMake(15, destinationContentHeight, 16, 16)];
    [imgSeparate setImage:[UIImage imageNamed:@"ico_cvmain_group.png"]];
    [self.viewExperience addSubview:imgSeparate];
    [imgSeparate release];
    
    //添加分割线
    CGRect frameSeparate = CGRectMake(22, destinationContentHeight+16, 1, 1);
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:frameSeparate];
    [lbSeparate setBackgroundColor:[UIColor colorWithRed:87.f/255.f green:212.f/255.f blue:117.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbSeparate];
    
    //公司名称
    UILabel *lbCompanyTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbCompanyTitle setFont:[UIFont systemFontOfSize:14]];
    [lbCompanyTitle setTextAlignment:NSTextAlignmentRight];
    [lbCompanyTitle setText:@"公司名称"];
    [lbCompanyTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbCompany = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbCompany setFont:[UIFont systemFontOfSize:14]];
    [lbCompany setTextAlignment:NSTextAlignmentLeft];
    [lbCompany setText:experienceData[@"CompanyName"]];
    [lbCompany setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbCompanyTitle];
    [self.viewExperience addSubview:lbCompany];
    [lbCompany release];
    [lbCompanyTitle release];
    destinationContentHeight += 27;
    
    //所属行业
    UILabel *lbIndustryTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbIndustryTitle setFont:[UIFont systemFontOfSize:14]];
    [lbIndustryTitle setTextAlignment:NSTextAlignmentRight];
    [lbIndustryTitle setText:@"所属行业"];
    [lbIndustryTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbIndustry = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbIndustry setFont:[UIFont systemFontOfSize:14]];
    [lbIndustry setTextAlignment:NSTextAlignmentLeft];
    [lbIndustry setText:experienceData[@"Industry"]];
    [lbIndustry setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbIndustryTitle];
    [self.viewExperience addSubview:lbIndustry];
    [lbIndustry release];
    [lbIndustryTitle release];
    
    //添加编辑、删除按钮
    UIButton *btnExperienceModify = [[UIButton alloc] initWithFrame:CGRectMake(270, destinationContentHeight, 30, 30)];
    [btnExperienceModify setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
    [btnExperienceModify setTitle:@"编辑" forState:UIControlStateNormal];
    btnExperienceModify.layer.cornerRadius = 5;
    [btnExperienceModify.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnExperienceModify.titleLabel setTextColor:[UIColor whiteColor]];
    [btnExperienceModify setTag:[experienceData[@"ID"] intValue]];
    [btnExperienceModify addTarget:self action:@selector(switchToExperienceModify:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewExperience addSubview:btnExperienceModify];
    [btnExperienceModify release];
    
    UIButton *btnExperienceDelete = [[UIButton alloc] initWithFrame:CGRectMake(270, destinationContentHeight+35, 30, 30)];
    [btnExperienceDelete setImage:[UIImage imageNamed:@"ico_cvmain_del.png"] forState:UIControlStateNormal];
    btnExperienceDelete.layer.cornerRadius = 5;
    btnExperienceDelete.layer.masksToBounds = YES;
    [btnExperienceDelete setTag:[experienceData[@"ID"] intValue]];
    [btnExperienceDelete addTarget:self action:@selector(deleteCvExperience:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewExperience addSubview:btnExperienceDelete];
    [btnExperienceDelete release];
    destinationContentHeight += 27;
    
    //公司规模
    UILabel *lbCompanySizeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbCompanySizeTitle setFont:[UIFont systemFontOfSize:14]];
    [lbCompanySizeTitle setTextAlignment:NSTextAlignmentRight];
    [lbCompanySizeTitle setText:@"公司规模"];
    [lbCompanySizeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbCompanySize = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbCompanySize setFont:[UIFont systemFontOfSize:14]];
    [lbCompanySize setTextAlignment:NSTextAlignmentLeft];
    [lbCompanySize setText:experienceData[@"CpmpanySize"]];
    [lbCompanySize setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbCompanySizeTitle];
    [self.viewExperience addSubview:lbCompanySize];
    [lbCompanySize release];
    [lbCompanySizeTitle release];
    destinationContentHeight += 27;
    
    //职位名称
    UILabel *lbJobNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbJobNameTitle setFont:[UIFont systemFontOfSize:14]];
    [lbJobNameTitle setTextAlignment:NSTextAlignmentRight];
    [lbJobNameTitle setText:@"职位名称"];
    [lbJobNameTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 120, 15)];
    [lbJobName setFont:[UIFont systemFontOfSize:14]];
    [lbJobName setTextAlignment:NSTextAlignmentLeft];
    [lbJobName setText:experienceData[@"JobName"]];
    [lbJobName setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbJobNameTitle];
    [self.viewExperience addSubview:lbJobName];
    [lbJobName release];
    [lbJobNameTitle release];
    destinationContentHeight += 27;
    
    //职位类别
    UILabel *lbJobTypeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbJobTypeTitle setFont:[UIFont systemFontOfSize:14]];
    [lbJobTypeTitle setTextAlignment:NSTextAlignmentRight];
    [lbJobTypeTitle setText:@"职位类别"];
    [lbJobTypeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbJobType = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbJobType setFont:[UIFont systemFontOfSize:14]];
    [lbJobType setTextAlignment:NSTextAlignmentLeft];
    [lbJobType setText:experienceData[@"JobType"]];
    [lbJobType setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbJobTypeTitle];
    [self.viewExperience addSubview:lbJobType];
    [lbJobType release];
    [lbJobTypeTitle release];
    destinationContentHeight += 27;
    
    //开始时间
    UILabel *lbBeginDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbBeginDateTitle setFont:[UIFont systemFontOfSize:14]];
    [lbBeginDateTitle setTextAlignment:NSTextAlignmentRight];
    [lbBeginDateTitle setText:@"开始时间"];
    [lbBeginDateTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbBeginDate = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbBeginDate setFont:[UIFont systemFontOfSize:14]];
    [lbBeginDate setTextAlignment:NSTextAlignmentLeft];
    [lbBeginDate setText:[NSString stringWithFormat:@"%@年%@月",[experienceData[@"BeginDate"] substringWithRange:NSMakeRange(0, 4)],[experienceData[@"BeginDate"] substringWithRange:NSMakeRange(4, 2)]]];
    [lbBeginDate setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbBeginDateTitle];
    [self.viewExperience addSubview:lbBeginDate];
    [lbBeginDate release];
    [lbBeginDateTitle release];
    destinationContentHeight += 27;
    
    //结束时间
    UILabel *lbEndDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbEndDateTitle setFont:[UIFont systemFontOfSize:14]];
    [lbEndDateTitle setTextAlignment:NSTextAlignmentRight];
    [lbEndDateTitle setText:@"结束时间"];
    [lbEndDateTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbEndDate = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbEndDate setFont:[UIFont systemFontOfSize:14]];
    [lbEndDate setTextAlignment:NSTextAlignmentLeft];
    if ([experienceData[@"EndDate"] isEqualToString:@"999999"]) {
        [lbEndDate setText:@"至今"];
    }
    else {
        [lbEndDate setText:[NSString stringWithFormat:@"%@年%@月",[experienceData[@"EndDate"] substringWithRange:NSMakeRange(0, 4)],[experienceData[@"EndDate"] substringWithRange:NSMakeRange(4, 2)]]];
    }
    [lbEndDate setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbEndDateTitle];
    [self.viewExperience addSubview:lbEndDate];
    [lbEndDate release];
    [lbEndDateTitle release];
    destinationContentHeight += 27;
    
    //下属人数
    UILabel *lbLowerNumberTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbLowerNumberTitle setFont:[UIFont systemFontOfSize:14]];
    [lbLowerNumberTitle setTextAlignment:NSTextAlignmentRight];
    [lbLowerNumberTitle setText:@"下属人数"];
    [lbLowerNumberTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbLowerNumber = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbLowerNumber setFont:[UIFont systemFontOfSize:14]];
    [lbLowerNumber setTextAlignment:NSTextAlignmentLeft];
    [lbLowerNumber setText:experienceData[@"LowerNumber"]];
    [lbLowerNumber setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewExperience addSubview:lbLowerNumberTitle];
    [self.viewExperience addSubview:lbLowerNumber];
    [lbLowerNumber release];
    [lbLowerNumberTitle release];
    destinationContentHeight += 27;
    
    //工作描述
    UILabel *lbDescriptionTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbDescriptionTitle setFont:[UIFont systemFontOfSize:14]];
    [lbDescriptionTitle setTextAlignment:NSTextAlignmentRight];
    [lbDescriptionTitle setText:@"工作描述"];
    [lbDescriptionTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbDescription setFont:[UIFont systemFontOfSize:14]];
    [lbDescription setTextAlignment:NSTextAlignmentLeft];
    [lbDescription setText:experienceData[@"Description"]];
    CGSize labelSize = [CommonController CalculateFrame:experienceData[@"Description"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(160, 5000)];
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
    [self.viewExperience addSubview:lbDescriptionTitle];
    [self.viewExperience addSubview:lbDescription];
    [lbDescription release];
    [lbDescriptionTitle release];
    
    frameSeparate.size.height = destinationContentHeight-contentHeight;
    [lbSeparate setFrame:frameSeparate];
    [lbSeparate release];
    
    destinationContentHeight += 35;
    return destinationContentHeight;
}

- (void)getCvSpecaility
{
    [self.lbSpeciality setText:self.cvData[0][@"Speciality"]];
    //计算工作能力文本的高度
    CGSize labelSize = [CommonController CalculateFrame:self.cvData[0][@"Speciality"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(270, 3000)];
    CGRect frameSpeciality = self.lbSpeciality.frame;
    frameSpeciality.size.height = labelSize.height;
    [self.lbSpeciality setFrame:frameSpeciality];
    //修改工作能力view的高度和Y
    CGRect frameViewSpeciality = self.viewSpeciality.frame;
    frameViewSpeciality.size.height = 100;
    frameViewSpeciality.size.height += labelSize.height-15;
    CGSize sizeScroll = self.scrollCvModify.contentSize;
    frameViewSpeciality.origin.y = sizeScroll.height;
    [self.viewSpeciality setFrame:frameViewSpeciality];
    sizeScroll.height = self.viewSpeciality.frame.origin.y+self.viewSpeciality.frame.size.height+15;
    [self.scrollCvModify setContentSize:sizeScroll];
}

- (IBAction)modifyCvName:(UIButton *)sender {
    [self.txtCvName resignFirstResponder];
    if (sender.tag == 1) {
        sender.tag = 0;
        [self.lbCvName setHidden:true];
        [self.txtCvName setHidden:false];
        [sender setTitle:@"确定" forState:UIControlStateNormal];
    }
    else {
        sender.tag = 1;
        [self updateCvName];
    }
}

- (IBAction)changePhoto:(UIButton *)sender {
    self.cPopup = [[[CustomPopup alloc] popupCommon:self.viewPhotoSelect buttonType:PopupButtonTypeNone] autorelease];
    [self.cPopup showPopup:self.view];
}

- (IBAction)selectPhotoFromCamera:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)selectPhotoFromAlbum:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)clostPopup:(id)sender {
    [self.cPopup closePopup];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeImage])
    {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        MLImageCrop *imgCrop = [[MLImageCrop alloc] init];
        imgCrop.delegate = self;
        imgCrop.image = chosenImage;
        imgCrop.ratioOfWidthAndHeight = 3.0f/4.0f;
        [imgCrop showWithAnimation:true];
    }
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeMovie])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息!" message:@"系统只支持图片格式" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage
{
    [self.btnPhoto setImage:cropImage forState:UIControlStateNormal];
    [self.cPopup closePopup];
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 0);
    NSLog(@"%d",dataPhoto.length);
    [self uploadPhoto:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

- (void)uploadPhoto:(NSString *)dataPhoto
{
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:dataPhoto forKey:@"stream"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UploadPhoto" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
}

- (IBAction)switchToPaModify:(id)sender {
    PaModifyViewController *paModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"PaModifyView"];
    paModifyC.cvId = self.cvId;
    [paModifyC.navigationItem setTitle:@"基本信息"];
    [self.navigationController pushViewController:paModifyC animated:true];
}

- (IBAction)switchToJobIntention:(UIButton *)sender {
    IntentionModifyViewController *intentionModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"IntentionModifyView"];
    intentionModifyC.cvId = self.cvId;
    [intentionModifyC.navigationItem setTitle:@"求职意向"];
    [self.navigationController pushViewController:intentionModifyC animated:true];
}

- (IBAction)switchToEducationModify:(UIButton *)sender {
    EducationModifyViewController *educationModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"EducationModifyView"];
    educationModifyC.cvId = self.cvId;
    [educationModifyC.navigationItem setTitle:@"教育背景"];
    educationModifyC.cvEducationId = [NSString stringWithFormat:@"%d",sender.tag];
    [self.navigationController pushViewController:educationModifyC animated:true];
}

- (IBAction)switchToExperienceModify:(UIButton *)sender {
    ExperienceModifyViewController *experienceModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"ExperienceModifyView"];
    experienceModifyC.cvId = self.cvId;
    [experienceModifyC.navigationItem setTitle:@"工作经历"];
    experienceModifyC.cvExperienceId = [NSString stringWithFormat:@"%d",sender.tag];
    [self.navigationController pushViewController:experienceModifyC animated:true];
}

- (IBAction)switchToSpeciality:(UIButton *)sender {
    SpecialitityModifyViewController *specialitityModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"SpecialitityModifyView"];
    specialitityModifyC.cvId = self.cvId;
    [specialitityModifyC.navigationItem setTitle:@"工作能力"];
    specialitityModifyC.specialitity = self.cvData[0][@"Speciality"];
    [self.navigationController pushViewController:specialitityModifyC animated:true];
}

- (IBAction)changeHasExp:(UIButton *)sender {
    [self.lbConfirmContent setText:@"确定要改为有工作经验吗？"];
    self.cPopup = [[[CustomPopup alloc] popupCommon:self.viewConfirm buttonType:PopupButtonTypeNone] autorelease];
    [self.cPopup setTag:3];
    [self.cPopup showPopup:self.view];
}

- (IBAction)changeNoExp:(UIButton *)sender {
    [self.lbConfirmContent setText:@"确定要改为无工作经验吗？"];
    self.cPopup = [[[CustomPopup alloc] popupCommon:self.viewConfirm buttonType:PopupButtonTypeNone] autorelease];
    [self.cPopup setTag:4];
    [self.cPopup showPopup:self.view];
}

- (void)deleteCvEducation:(UIButton *)sender {
    [self.lbConfirmContent setText:@"确定要删除该教育背景吗？"];
    self.cPopup = [[[CustomPopup alloc] popupCommon:self.viewConfirm buttonType:PopupButtonTypeNone] autorelease];
    [self.btnConfirmOK setTag:sender.tag];
    [self.cPopup setTag:1];
    [self.cPopup showPopup:self.view];
}

- (void)deleteCvExperience:(UIButton *)sender {
    [self.lbConfirmContent setText:@"确定要删除该工作经历吗？"];
    self.cPopup = [[[CustomPopup alloc] popupCommon:self.viewConfirm buttonType:PopupButtonTypeNone] autorelease];
    [self.btnConfirmOK setTag:sender.tag];
    [self.cPopup setTag:2];
    [self.cPopup showPopup:self.view];
}

- (IBAction)confirmOK:(UIButton *)sender {
    [self.cPopup closePopup];
    switch (self.cPopup.tag) {
        case 1: //删除教育背景
        {
            if (![loadView isAnimating]) {
                [loadView startAnimating];
            }
            NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
            [dicParam setObject:[NSString stringWithFormat:@"%d",sender.tag] forKey:@"iD"];
            [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
            [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
            NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteEducation" Params:dicParam];
            [request setDelegate:self];
            [request startAsynchronous];
            request.tag = 3;
            self.runningRequest = request;
            [dicParam release];
            break;
        }
        case 2: //删除工作经验
        {
            if (![loadView isAnimating]) {
                [loadView startAnimating];
            }
            NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
            [dicParam setObject:[NSString stringWithFormat:@"%d",sender.tag] forKey:@"iD"];
            [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
            [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
            NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteExperience" Params:dicParam];
            [request setDelegate:self];
            [request startAsynchronous];
            request.tag = 4;
            self.runningRequest = request;
            [dicParam release];
            break;
        }
        case 3: //改为有工作经验
        {
            [self changeCvType:@"0"];
            break;
        }
        case 4: //改为无工作经验
        {
            [self changeCvType:@"1"];
            break;
        }
        default:
            break;
    }
}

- (void)changeCvType:(NSString *)cvType
{
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:cvType forKey:@"cvType"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateCvType" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    if ([cvType isEqualToString:@"0"]) {
        request.tag = 5;
    }
    else {
        request.tag = 6;
    }
    self.runningRequest = request;
    [dicParam release];
}

- (IBAction)confirmCancel:(UIButton *)sender {
    [self.cPopup closePopup];
}

- (void)updateCvName
{
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:@"0" forKey:@"type"];
    [dicParam setObject:self.txtCvName.text forKey:@"cvName"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateCvName" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if (request.tag == 1) {
        [self.view makeToast:@"简历名称修改成功"];
        [self.lbCvName setHidden:false];
        [self.lbCvName setText:self.txtCvName.text];
        [self.txtCvName setHidden:true];
        [self.btnCvName setTitle:@"编辑名称" forState:UIControlStateNormal];
    }
    else if (request.tag == 2) {
        [self.view makeToast:@"头像上传成功"];
    }
    else if (request.tag == 3) {
        [self.view makeToast:@"删除教育背景成功"];
        [self getCvInfo];
    }
    else if (request.tag == 4) {
        [self.view makeToast:@"删除工作能力成功"];
        [self getCvInfo];
    }
    else if (request.tag == 5) {
        [self.view makeToast:@"已修改为有工作经验"];
        [self.btnSetHasExp setBackgroundImage:[UIImage imageNamed:@"radio_sel.png"] forState:UIControlStateNormal];
        [self.btnSetHasExp setEnabled:false];
        [self.btnSetNoExp setBackgroundImage:[UIImage imageNamed:@"radio_unsel.png"] forState:UIControlStateNormal];
        [self.btnSetNoExp setEnabled:true];
        [self.btnAddExperience setHidden:false];
    }
    else if (request.tag == 6) {
        [self.view makeToast:@"已修改为无工作经验"];
        [self.btnSetHasExp setBackgroundImage:[UIImage imageNamed:@"radio_unsel.png"] forState:UIControlStateNormal];
        [self.btnSetHasExp setEnabled:true];
        [self.btnSetNoExp setBackgroundImage:[UIImage imageNamed:@"radio_sel.png"] forState:UIControlStateNormal];
        [self.btnSetNoExp setEnabled:false];
        [self.btnAddExperience setHidden:true];
    }
    [loadView stopAnimating];
}

- (void)netRequestFinishedFromCvInfo:(NetWebServiceRequest *)request
                          xmlContent:(GDataXMLDocument *)xmlContent
{
    
    self.cvData = [self getArrayFromXml:xmlContent tableName:@"Table1"];
    self.paData = [self getArrayFromXml:xmlContent tableName:@"paData"];
    [self getCvBasic];
    [self getPaBasic];
    [self getJobIntention:[self getArrayFromXml:xmlContent tableName:@"Table4"]];
    [self getCvEducation:[self getArrayFromXml:xmlContent tableName:@"Table2"]];
    [self getCvExperience:[self getArrayFromXml:xmlContent tableName:@"Table3"]];
    [self getCvSpecaility];
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

- (IBAction)textFiledReturnEditing:(id)sender
{
    [self.txtCvName resignFirstResponder];
}

- (int)getCvLevelScore:(NSString *)cvLevel
              hasPhoto:(NSString *)hasPhoto
{
    //根据CvLevel 计算简历评分
    int intScore = 0;
    if ([[cvLevel substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 20;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 20;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 15;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 15;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 5;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 5;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 5;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(8, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 5;
    }
    if ([[cvLevel substringWithRange:NSMakeRange(9, 1)] isEqualToString:@"1"]) {
        intScore = intScore + 5;
    }
    if (hasPhoto) {
        intScore = intScore + 5;
    }
    return intScore;
}

-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count]>0){
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediatypes;
        picker.delegate = self;
        picker.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [picker setMediaTypes:arrmediatypes];
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
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

- (void)dealloc {
    [loadView release];
    [_runningRequest release];
    [_cPopup release];
    [_userDefaults release];
    [_cvData release];
    [_paData release];
    [_lbCvName release];
    [_btnCvName release];
    [_txtCvName release];
    [_lbCvScore release];
    [_lbPaName release];
    [_lbGender release];
    [_lbBirth release];
    [_lbLivePlace release];
    [_lbAccountPlace release];
    [_lbGrowPlace release];
    [_lbMobile release];
    [_lbEmail release];
    [_viewPaInfo release];
    [_viewPhotoSelect release];
    [_btnPhoto release];
    [_scrollCvModify release];
    [_viewJobIntention release];
    [_lbExperience release];
    [_lbEmployType release];
    [_lbSalary release];
    [_lbExpectJobPlace release];
    [_lbExpectJobType release];
    [_lbExpectJobTypeTitle release];
    [_lbSpeciality release];
    [_viewSpeciality release];
    [_viewEducation release];
    [_viewExperience release];
    [_viewSetExperience release];
    [_btnAddExperience release];
    [_btnAddEducation release];
    [_btnPhotoCancel release];
    [_lbConfirmContent release];
    [_viewConfirm release];
    [_btnConfirmOK release];
    [_btnConfirmCancel release];
    [_btnSetHasExp release];
    [_btnSetNoExp release];
    [super dealloc];
}
@end
