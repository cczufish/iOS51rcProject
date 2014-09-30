//
//  MyCvViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-12.
//

#import "MyCvViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"
#import "Toast+UIView.h"
#import "CustomPopup.h"
#import "CreateResumeAlertViewController.h"
#import "CvModifyViewController.h"
#import "CvViewViewController.h"
#import "RefreshCvViewController.h"

@interface MyCvViewController ()<NetWebServiceRequestDelegate,UIScrollViewDelegate,CreateResumeDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSArray *cvListData;
@property (nonatomic, retain) NSString *cvId;
@property (nonatomic, retain) CustomPopup *cPopup;

@end

@implementation MyCvViewController

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
    [self.navigationItem setTitle:@"我的简历"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [loadView startAnimating];
    self.btnCreateCv.layer.cornerRadius = 5;
    self.btnConfirm.layer.cornerRadius = 5;
    self.btnConfirmCancel.layer.cornerRadius = 5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.toastType == 1) {
        [self.view makeToast:@"简历更新成功"];
    }
    self.toastType = 0;
    [self getCvList];
}

- (void)getCvList
{
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetBasicCvListByPaMainID" Params:dicParam];
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
        self.lbCvCount.text = [NSString stringWithFormat:@"已创建%d份简历，还可再创建%d份简历",requestData.count,(3-requestData.count)];
        self.cvListData = requestData;
        for (UIView *view in self.scrollCv.subviews) {
            [view removeFromSuperview];
        }
        if (requestData.count == 0) { //没有简历
            [self.scrollCv setContentSize:CGSizeMake(320, self.scrollCv.frame.size.height)];
            //显示提醒
            [self.pageControl setHidden:true];
            [self.viewNoCv setHidden:false];
            [self.viewCvEdit setHidden:true];
            CGRect frameCreate = self.viewCreate.frame;
            frameCreate.origin.y = 0;
            [self.viewCreate setFrame:frameCreate];
        }
        else { //有简历
            [self.scrollCv setContentSize:CGSizeMake(320*requestData.count, self.scrollCv.frame.size.height)];
            [self.scrollCv setContentOffset:CGPointMake(0, 0)];
            [self.pageControl setNumberOfPages:0];
            //显示提醒
            [self.pageControl setHidden:false];
            [self.viewNoCv setHidden:true];
            [self.viewCvEdit setHidden:false];
            CGRect frameCreate = self.viewCreate.frame;
            frameCreate.origin.y = 100;
            [self.viewCreate setFrame:frameCreate];
            if (requestData.count > 2) {
                [self.btnCreateCv setEnabled:false];
            }
            else {
                [self.btnCreateCv setEnabled:true];
            }
            
            [self.pageControl setNumberOfPages:requestData.count];
            for (int i=0; i<requestData.count; i++)
            {
                [self buildCvList:requestData[i] numberOfCv:i];
            }
        }
    }
    else if (request.tag == 2) {
        [self.view makeToast:@"已设置成功"];
    }
    else if (request.tag == 3) {
        [loadView stopAnimating];
        if ([result isEqualToString:@"0"]) {
            [self.view makeToast:@"已经创建了3份简历了"];
            return;
        }
        CvModifyViewController *cvModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"CvModifyView"];
        cvModifyC.cvId = result;
        [self.navigationController pushViewController:cvModifyC animated:true];
    }
    else if (request.tag == 5) {
        [self.view makeToast:@"简历删除成功"];
        [self getCvList];
    }
    [loadView stopAnimating];
}

- (void)buildCvList:(NSDictionary *)dicCvInfo
         numberOfCv:(int)numberOfCv
{
    if (numberOfCv == 0) {
        self.cvId = dicCvInfo[@"ID"];
    }
    float fltContentX = 320*numberOfCv;
    //简历名称+更新日期
    UILabel *lbCvName = [[UILabel alloc] initWithFrame:CGRectMake(fltContentX+20, 20, 170, 20)];
    [lbCvName setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
    [lbCvName setFont:[UIFont systemFontOfSize:14]];
    [lbCvName setText:dicCvInfo[@"Name"]];
    [self.scrollCv addSubview:lbCvName];
    [lbCvName release];
    
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(fltContentX+190, 20, 100, 20)];
    [lbRefreshDate setTextColor:[UIColor grayColor]];
    [lbRefreshDate setFont:[UIFont systemFontOfSize:10]];
    [lbRefreshDate setTextAlignment:NSTextAlignmentRight];
    [lbRefreshDate setText:[NSString stringWithFormat:@"更新日期:%@",[CommonController stringFromDateString:dicCvInfo[@"RefreshDate"] formatType:@"yyyy-MM-dd"]]];
    [self.scrollCv addSubview:lbRefreshDate];
    [lbRefreshDate release];
    
    //头像处理
    UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(fltContentX+35, 60, 64, 80)];
    [imgPhoto setImage:[UIImage imageNamed:@"pic_pahead_default.png"]];
    if (dicCvInfo[@"PhotoProcess"])
    {
        if (![dicCvInfo[@"HasPhoto"] isEqualToString:@"2"]) {
            NSString *path = [NSString stringWithFormat:@"%d",([[self.userDefaults objectForKey:@"UserID"] intValue] / 100000 + 1) * 100000];
            for (int i=0; i<9-path.length; i++) {
                path = [NSString stringWithFormat:@"0%@",path];
            }
            path = [NSString stringWithFormat:@"L%@",path];
            path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Photo/%@/Processed/%@",path,dicCvInfo[@"PhotoProcess"]];
            [imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]]];
        }
    }
    [self.scrollCv addSubview:imgPhoto];
    [imgPhoto release];
    
    //显示简历完整度
    MDRadialProgressTheme *themeCvLevel = [[MDRadialProgressTheme alloc] init];
	themeCvLevel.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
	themeCvLevel.incompletedColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    MDRadialProgressView *viewCvLevel = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(fltContentX+130, 60, 60, 60) andTheme:themeCvLevel];
    viewCvLevel.progressTotal = 100;
    viewCvLevel.progressCounter = [self getCvLevelScore:dicCvInfo[@"cvLevel"] hasPhoto:dicCvInfo[@"HasPhoto"]];
    viewCvLevel.unit = @"分";
	viewCvLevel.theme.sliceDividerHidden = YES;
    [self.scrollCv addSubview:viewCvLevel];
    [themeCvLevel release];
    [viewCvLevel release];
    
    UILabel *lbCvLevel = [[UILabel alloc] initWithFrame:CGRectMake(fltContentX+130, 120, 60, 20)];
    [lbCvLevel setText:@"简历完整度"];
    [lbCvLevel setTextAlignment:NSTextAlignmentCenter];
    [lbCvLevel setFont:[UIFont systemFontOfSize:10]];
    [self.scrollCv addSubview:lbCvLevel];
    [lbCvLevel release];
    //显示简历被浏览量
    MDRadialProgressTheme *themeCvview = [[MDRadialProgressTheme alloc] init];
	themeCvview.completedColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:0.5];
	themeCvview.incompletedColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:0.2];
    
    MDRadialProgressView *viewCvview = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(fltContentX+215, 60, 60, 60) andTheme:themeCvview];
    [themeCvview release];
    viewCvview.progressCount = [dicCvInfo[@"ViewNumber"] intValue];
	viewCvview.theme.sliceDividerHidden = YES;
    [self.scrollCv addSubview:viewCvview];
    [viewCvview release];
    
    UILabel *lbCvview = [[UILabel alloc] initWithFrame:CGRectMake(fltContentX+215, 120, 60, 20)];
    [lbCvview setText:@"简历被浏览量"];
    [lbCvview setTextAlignment:NSTextAlignmentCenter];
    [lbCvview setFont:[UIFont systemFontOfSize:10]];
    [self.scrollCv addSubview:lbCvview];
    [lbCvview release];
    
    //添加分割线
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:CGRectMake(fltContentX+30, 155, 260, 0.5)];
    [lbSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [self.scrollCv addSubview:lbSeparate];
    [lbSeparate release];
    //添加姓名公开
    UIButton *btnNameHidden = [[UIButton alloc] initWithFrame:CGRectMake(fltContentX+40, 170, 100, 27)];
    [btnNameHidden.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnNameHidden addTarget:self action:@selector(changeNameHidden:) forControlEvents:UIControlEventTouchUpInside];
    if ([dicCvInfo[@"IsNameHidden"] isEqualToString:@"false"]) {
        [btnNameHidden setTitle:@"姓名已公开" forState:UIControlStateNormal];
        [btnNameHidden setBackgroundImage:[UIImage imageNamed:@"ico_setting_on.png"] forState:UIControlStateNormal];
        [btnNameHidden setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        btnNameHidden.tag = 1;
    }
    else {
        [btnNameHidden setTitle:@"姓名已隐藏" forState:UIControlStateNormal];
        [btnNameHidden setBackgroundImage:[UIImage imageNamed:@"ico_setting_off.png"] forState:UIControlStateNormal];
        [btnNameHidden setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        btnNameHidden.tag = 0;
    }
    [self.scrollCv addSubview:btnNameHidden];
    [btnNameHidden release];
    
    //添加简历公开
    UIButton *btnCvHidden = [[UIButton alloc] initWithFrame:CGRectMake(fltContentX+180, 170, 100, 27)];
    [btnCvHidden.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btnCvHidden addTarget:self action:@selector(changeCvHidden:) forControlEvents:UIControlEventTouchUpInside];
    if ([dicCvInfo[@"IscvHidden"] isEqualToString:@"false"]) {
        [btnCvHidden setTitle:@"简历已公开" forState:UIControlStateNormal];
        [btnCvHidden setBackgroundImage:[UIImage imageNamed:@"ico_setting_on.png"] forState:UIControlStateNormal];
        [btnCvHidden setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        btnCvHidden.tag = 1;
    }
    else {
        [btnCvHidden setTitle:@"简历已隐藏" forState:UIControlStateNormal];
        [btnCvHidden setBackgroundImage:[UIImage imageNamed:@"ico_setting_off.png"] forState:UIControlStateNormal];
        [btnCvHidden setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        btnCvHidden.tag = 0;
    }
    [self.scrollCv addSubview:btnCvHidden];
    [btnCvHidden release];
    
    //添加方向键
    if (numberOfCv < self.cvListData.count-1) {
        UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(fltContentX+300, 0, 20, self.scrollCv.frame.size.height)];
        [btnNext addTarget:self action:@selector(showNextCv) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgNext = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 10, 20)];
        [imgNext setImage:[UIImage imageNamed:@"ico_mapsearch_next.png"]];
        [btnNext addSubview:imgNext];
        [self.scrollCv addSubview:btnNext];
        [imgNext release];
        [btnNext release];
    }
    
    if (numberOfCv > 0) {
        UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(fltContentX, 0, 20, self.scrollCv.frame.size.height)];
        [btnPrev addTarget:self action:@selector(showPrevCv) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imgPrev = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 10, 20)];
        [imgPrev setImage:[UIImage imageNamed:@"ico_mapsearch_pre.png"]];
        [btnPrev addSubview:imgPrev];
        [self.scrollCv addSubview:btnPrev];
        [imgPrev release];
        [btnPrev release];
    }
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = scrollView.contentOffset.x/320;
    [self.pageControl setCurrentPage:currentPage];
    self.cvId = self.cvListData[currentPage][@"ID"];
}

- (void)changeNameHidden:(UIButton *)sender
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",sender.tag] forKey:@"isHidden"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateIsNameHidden" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
    
    //更改按钮
    if (sender.tag == 0) {
        [sender setTitle:@"姓名已公开" forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico_setting_on.png"] forState:UIControlStateNormal];
        [sender setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        sender.tag = 1;
    }
    else {
        [sender setTitle:@"姓名已隐藏" forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico_setting_off.png"] forState:UIControlStateNormal];
        [sender setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        sender.tag = 0;
    }
}

- (void)changeCvHidden:(UIButton *)sender
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",sender.tag] forKey:@"isHidden"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateIsCvHidden" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
    
    //更改按钮
    if (sender.tag == 0) {
        [sender setTitle:@"简历已公开" forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico_setting_on.png"] forState:UIControlStateNormal];
        [sender setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        sender.tag = 1;
    }
    else {
        [sender setTitle:@"简历已隐藏" forState:UIControlStateNormal];
        [sender setBackgroundImage:[UIImage imageNamed:@"ico_setting_off.png"] forState:UIControlStateNormal];
        [sender setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        sender.tag = 0;
    }
}

- (void)showNextCv
{
    int currentPage = self.pageControl.currentPage;
    [self.scrollCv setContentOffset:CGPointMake(320*(currentPage+1), 0) animated:true];
    [self.pageControl setCurrentPage:(currentPage+1)];
    self.cvId = self.cvListData[(currentPage+1)][@"ID"];
}

- (void)showPrevCv
{
    int currentPage = self.pageControl.currentPage;
    [self.scrollCv setContentOffset:CGPointMake(320*(currentPage-1), 0) animated:true];
    [self.pageControl setCurrentPage:(currentPage-1)];
    self.cvId = self.cvListData[(currentPage-1)][@"ID"];
}

- (IBAction)createCv:(id)sender {
    CreateResumeAlertViewController *viewCreateCv = [[CreateResumeAlertViewController alloc] init];
    viewCreateCv.delegate = self;
    self.cPopup = [[[CustomPopup alloc] popupCommon:viewCreateCv.view buttonType:PopupButtonTypeNone] autorelease];
    [self.cPopup setTag:1];
    [self.cPopup showPopup:self.view];
}

-(void) CreateResume:(BOOL) hasExp
{
    int cvType = 1;
    if (hasExp) {
        cvType = 0;
    }
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",cvType] forKey:@"type"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"CreateResume" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 3;
    self.runningRequest = request;
    [dicParam release];
    [self.cPopup closePopup];
}

- (IBAction)swichToCvModify:(id)sender {
    CvModifyViewController *cvModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"CvModifyView"];
    cvModifyC.cvId = self.cvId;
    [self.navigationController pushViewController:cvModifyC animated:true];
}

- (IBAction)switchToCvView:(id)sender {
    CvViewViewController *cvViewC = [self.storyboard instantiateViewControllerWithIdentifier:@"CvViewView"];
    cvViewC.cvId = self.cvId;
    [self.navigationController pushViewController:cvViewC animated:true];
}

- (IBAction)switchToCvRefresh:(id)sender {
    RefreshCvViewController *refreshViewC = [self.storyboard instantiateViewControllerWithIdentifier:@"RefreshCvView"];
    refreshViewC.cvId = self.cvId;
    refreshViewC.mobile = self.cvListData[0][@"Mobile"];
    [self.navigationController pushViewController:refreshViewC animated:true];
}

- (IBAction)deleteCv:(id)sender {
    self.cPopup = [[[CustomPopup alloc] popupCommon:self.viewConfirm buttonType:PopupButtonTypeNone] autorelease];
    [self.cPopup setTag:2];
    [self.cPopup showPopup:self.view];
}

- (IBAction)confirmCancel:(id)sender {
    [self.cPopup closePopup];
}

- (IBAction)confirmOK:(id)sender {
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ResumeDelete" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 5;
    self.runningRequest = request;
    [dicParam release];
    [self.cPopup closePopup];
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
    [_pageControl release];
    [_scrollCv release];
    [_runningRequest release];
    [loadView release];
    [_viewNoCv release];
    [_viewCvEdit release];
    [_lbCvCount release];
    [_viewCreate release];
    [_userDefaults release];
    [_cvId release];
    [_btnCreateCv release];
    [_cvListData release];
    [_cPopup release];
    [_btnConfirmCancel release];
    [_btnConfirm release];
    [_viewConfirm release];
    [super dealloc];
}
@end
