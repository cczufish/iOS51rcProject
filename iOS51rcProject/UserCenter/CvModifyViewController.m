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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [loadView startAnimating];
    
    //添加边框
    self.btnCvName.layer.cornerRadius = 5;
    self.btnCvName.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.btnCvName.layer.borderWidth = 1;
    self.viewPaInfo.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewPaInfo.layer.borderWidth = 0.5;
    self.viewJobIntention.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewJobIntention.layer.borderWidth = 0.5;
    self.viewSpeciality.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewSpeciality.layer.borderWidth = 0.5;
    self.viewEducation.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewEducation.layer.borderWidth = 0.5;
    self.viewExperience.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewExperience.layer.borderWidth = 0.5;
    self.btnPhotoCancel.layer.cornerRadius = 5;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)getCvBasic
{
    [self.lbCvName setText:self.cvData[0][@"Name"]];
    [self.txtCvName setText:self.cvData[0][@"Name"]];
    [self.lbCvScore setText:[NSString stringWithFormat:@"%d分",[self getCvLevelScore:self.cvData[0][@"cvLevel"] hasPhoto:self.paData[0][@"HasPhoto"]]]];
}

- (void)getPaBasic
{
    if (!self.paData[0][@"BirthDay"]) {
        return;
    }
    [self.lbPaName setText:self.paData[0][@"Name"]];
    [self.lbLivePlace setText:self.paData[0][@"LiveRegion"]];
    [self.lbAccountPlace setText:self.paData[0][@"AccountRegion"]];
    [self.lbGrowPlace setText:self.paData[0][@"GrowRegion"]];
    [self.lbMobile setText:self.paData[0][@"Mobile"]];
    [self.lbEmail setText:self.paData[0][@"Email"]];
    [self.lbBirth setText:[NSString stringWithFormat:@"%@年%@月",[self.paData[0][@"BirthDay"] substringWithRange:NSMakeRange(0, 4)],[self.paData[0][@"BirthDay"] substringWithRange:NSMakeRange(4, 2)]]];
    if ([self.paData[0][@"Gender"] isEqualToString:@"false"]) {
        [self.lbGender setText:@"男"];
    }
    else {
        [self.lbGender setText:@"女"];
    }
}

- (void)getJobIntention:(NSArray *)arrayCvIntention
{
    CGRect frameViewJobIntention = self.viewJobIntention.frame;
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
        frameExpectJobType.origin.y += labelSize.height-15;
        [self.lbExpectJobType setFrame:frameExpectJobType];
        
        CGRect frameExpectJobTypeTitle = self.lbExpectJobTypeTitle.frame;
        frameExpectJobTypeTitle.origin.y += labelSize.height-15;
        [self.lbExpectJobTypeTitle setFrame:frameExpectJobTypeTitle];
        //修改求职意向view的高度
        frameViewJobIntention.size.height += labelSize.height-15;
    }
    labelSize = [CommonController CalculateFrame:arrayCvIntention[0][@"JobTypeName"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(160, 300)];
    if (labelSize.height > 20) {
        CGRect frameExpectJobType = self.lbExpectJobType.frame;
        frameExpectJobType.size.height = labelSize.height;
        [self.lbExpectJobType setFrame:frameExpectJobType];
        //修改求职意向view的高度
        frameViewJobIntention.size.height += labelSize.height-15;
    }
    [self.viewJobIntention setFrame:frameViewJobIntention];
    [self.scrollCvModify setContentSize:CGSizeMake(320, self.viewJobIntention.frame.origin.y+self.viewJobIntention.frame.size.height+15)];
}

- (void)getCvEducation:(NSArray *)arrayCvEducation
{
    if (arrayCvEducation.count > 19) {
        [self.btnAddEducation setHidden:true];
    }
    else {
        [self.btnAddEducation setHidden:false];
    }
    float heightViewEducation = 65;
    for (NSDictionary *dicEducation in arrayCvEducation) {
        heightViewEducation = [self fillCvEducation:dicEducation contentHeight:heightViewEducation];
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
{
    float destinationContentHeight = contentHeight;
    //添加分割线的球形
    UIImageView *imgSeparate = [[UIImageView alloc] initWithFrame:CGRectMake(10, destinationContentHeight, 16, 16)];
    [imgSeparate setImage:[UIImage imageNamed:@"ico_cvmain_group.png"]];
    [self.viewEducation addSubview:imgSeparate];
    [imgSeparate release];
    
    //添加分割线
    CGRect frameSeparate = CGRectMake(17, destinationContentHeight+16, 1, 1);
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
    
    UILabel *lbGraduationDate = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
    [lbGraduationDate setFont:[UIFont systemFontOfSize:14]];
    [lbGraduationDate setTextAlignment:NSTextAlignmentLeft];
    [lbGraduationDate setText:[NSString stringWithFormat:@"%@年%@月",[educationData[@"Graduation"] substringWithRange:NSMakeRange(0, 4)],[educationData[@"Graduation"] substringWithRange:NSMakeRange(4, 2)]]];
    [lbGraduationDate setTextColor:[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:144.f/255.f alpha:1]];
    [self.viewEducation addSubview:lbGraduationDateTitle];
    [self.viewEducation addSubview:lbGraduationDate];
    [lbGraduationDate release];
    [lbGraduationDateTitle release];
    destinationContentHeight += 27;
    
    //学历
    UILabel *lbDegreeTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, destinationContentHeight, 90, 15)];
    [lbDegreeTitle setFont:[UIFont systemFontOfSize:14]];
    [lbDegreeTitle setTextAlignment:NSTextAlignmentRight];
    [lbDegreeTitle setText:@"学历"];
    [lbDegreeTitle setTextColor:[UIColor colorWithRed:90.f/255.f green:99.f/255.f blue:103.f/255.f alpha:1]];
    
    UILabel *lbDegree = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
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
    
    UILabel *lbEducationType = [[UILabel alloc] initWithFrame:CGRectMake(140, destinationContentHeight, 160, 15)];
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
    [lbMajorNameTitle setText:@"专业"];
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
    
    //修改位置和高度
    CGRect frameViewExperience = self.viewExperience.frame;
//    frameViewExperience.size.height += labelSize.height-15;
    CGSize sizeScroll = self.scrollCvModify.contentSize;
    frameViewExperience.origin.y = sizeScroll.height;
    [self.viewExperience setFrame:frameViewExperience];
    sizeScroll.height = self.viewExperience.frame.origin.y+self.viewExperience.frame.size.height+15;
    [self.scrollCvModify setContentSize:sizeScroll];
}

- (void)getCvSpecaility
{
    [self.lbSpeciality setText:self.cvData[0][@"Speciality"]];
    //计算工作能力文本的高度
    CGSize labelSize = [CommonController CalculateFrame:self.cvData[0][@"Speciality"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(270, 300)];
    CGRect frameSpeciality = self.lbSpeciality.frame;
    frameSpeciality.origin.y += labelSize.height-15;
    [self.lbSpeciality setFrame:frameSpeciality];
    //修改工作能力view的高度和Y
    CGRect frameViewSpeciality = self.viewSpeciality.frame;
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
    self.cPopup = [[CustomPopup alloc] popupCommon:self.viewPhotoSelect buttonType:PopupButtonTypeNone];
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
}
- (IBAction)switchToJobIntention:(UIButton *)sender {
}

- (IBAction)switchToEducationModify:(UIButton *)sender {
}
- (IBAction)switchToExperienceModify:(UIButton *)sender {
}
- (IBAction)switchToSpeciality:(UIButton *)sender {
}

- (IBAction)changeNoExp:(UIButton *)sender {
}
- (IBAction)changeHasExp:(UIButton *)sender {
}

- (IBAction)setCvType:(id)sender {
}
- (IBAction)cancelSetCvType:(id)sender {
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
    [_lbSetExperienceContent release];
    [_btnSetExperienceCancel release];
    [_btnSetExperienceOk release];
    [super dealloc];
}
@end
