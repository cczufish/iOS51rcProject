#import "CpAttentionViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "SearchPickerView.h"
#import "Toast+UIView.h"
#import "DictionaryPickerView.h"
#import "LoginViewController.h"
#import "CustomPopup.h"
#import "JobViewController.h"
#import "SuperJobMainViewController.h"
#import "SuperCpViewController.h"

@interface CpAttentionViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,DictionaryPickerDelegate,CustomPopupDelegate>
{
    LoadingAnimationView *loadView;
    NSString *selectCV;
}
@property (nonatomic, retain) NSMutableArray *cvList;
@property (nonatomic, retain) NSMutableArray *jobListData;
@property int pageNumber;
@property (nonatomic, retain) NSString *isOnline;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NetWebServiceRequest *runningRequestGetCvList;
@property (nonatomic, retain) CustomPopup *cPopup;
@property (retain, nonatomic) IBOutlet UILabel *lbTop;
@property (retain, nonatomic) IBOutlet UIButton *btnTop;
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@end

@implementation CpAttentionViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)cancelDicPicker
{
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
    
    //切换背景图片
    UIImageView *imgCornor = self.btnTop.subviews[1];
    imgCornor.image = [UIImage imageNamed:@"ico_triangle.png"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.frame = CGRectMake(0, 0, 320, HEIGHT-210);
    //self.tvJobList.frame = CGRectMake(0, 40, 320, HEIGHT-250);
    self.lbTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lbTop.layer.borderWidth = 0.5;
    self.btnTop.titleLabel.text = @"相关简历";
    self.btnTop.titleLabel.font = [UIFont systemFontOfSize:12];
    self.btnTop.layer.borderWidth = 0.5;
    self.btnTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.btnTop addTarget:self action:@selector(selectCV:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgCornor = [[[UIImageView alloc] initWithFrame:CGRectMake(65, 20, 10, 10)] autorelease];
    imgCornor.image = [UIImage imageNamed:@"ico_triangle.png"];
    [self.btnTop addSubview:imgCornor];
    
    self.pageNumber = 1;
    self.arrCheckJobID = [[NSMutableArray alloc] init];
    //设置导航标题(搜索条件)
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 125, 45)];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, viewTitle.frame.size.width, 20)];
    [lbTitle setFont:[UIFont systemFontOfSize:12]];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    //[viewTitle setBackgroundColor:[UIColor blueColor]];
    [viewTitle addSubview:lbTitle];

    [self.navigationItem setTitleView:viewTitle];
    [viewTitle release];
    [lbTitle release];

     self.tvJobList.frame = CGRectMake(0, self.tvJobList.frame.origin.y, 320, HEIGHT-160);
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self GetBasicCvList];
    selectCV = @"";
}

- (void)onSearch
{
    if (self.pageNumber == 1) {
        [self.jobListData removeAllObjects];
        [self.tvJobList reloadData];
        //开始等待动画
        [loadView startAnimating];
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];//21142013
    [dicParam setObject:code forKey:@"code"];//152014391908
    [dicParam setObject:selectCV forKey:@"cvMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvViewLog" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) { //职位搜索
        if (requestData.count>0) {
            if(self.pageNumber == 1){
                [self.jobListData removeAllObjects];
                self.jobListData = requestData;
            }
            else{
                [self.jobListData addObjectsFromArray:requestData];
            }
            [self.tvJobList footerEndRefreshing];
            //重新加载列表
            [self.tvJobList reloadData];
        }else{
            //没有面试通知记录
            self.lbTop.text = @" ";
            self.lbTop.layer.borderColor = [UIColor whiteColor].CGColor;
            self.btnTop.layer.borderWidth = 0;
            UIImageView *imgCornor = self.btnTop.subviews[1];
            imgCornor.image = [UIImage imageNamed:@"11111"];//赋空值
            self.btnTop.titleLabel.text = @" ";
            
            UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(20, 100, 240, 80)]autorelease];
            UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)] autorelease];
            img.image = [UIImage imageNamed:@"pic_noinfo.png"];
            [viewHsaNoCv addSubview:img];
            
            UILabel *lb1 = [[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 220, 20)] autorelease];
            lb1.text = @"亲，没有谁在关注我的记录,建议您";
            lb1.font = [UIFont systemFontOfSize:14];
            lb1.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb1];
            
            UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(50, 30, 210, 20)] autorelease];
            lb2.text = @"去我们的简历库看看，";
            lb2.font = [UIFont systemFontOfSize:14];
            lb2.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
            lb2.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb2];
            UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 20)] autorelease];
            lb3.text = @"会发现不一样的惊喜";
            lb3.font = [UIFont systemFontOfSize:14];
            lb3.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb3];
            
            [self.view addSubview:viewHsaNoCv];
        }
    }
    else if(request.tag == 2){
        NSMutableArray *arrCv = [[NSMutableArray alloc] init];
        NSDictionary *defalult = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"0",@"id",
                                   @"相关简历",@"value"
                                   ,nil] autorelease];
        [arrCv addObject:defalult];
        for (int i = 0; i < requestData.count; i++) {
            if (![requestData[i][@"Name"] isEqualToString:@"未完成简历"]) {
                NSDictionary *dicCv = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                    requestData[i][@"ID"],@"id",
                                    requestData[i][@"Name"],@"value"
                                    ,nil] autorelease];
                [arrCv addObject:dicCv];
                 }
        }
        
        self.cvList = arrCv;
    }

    //结束等待动画
    [loadView stopAnimating];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *colorText = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1];
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    NSDictionary *rowData = self.jobListData[indexPath.row];
    //审核图标
    UIImageView *imgShen = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 14, 14)];
    imgShen.image = [UIImage imageNamed:@"ico_shen.png"];
    [cell.contentView addSubview:imgShen];
    [imgShen release];  
    
    //公司名称
    UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(35, 5, 200, 20)];
    [lbCompanyName setText:rowData[@"cpName"]];
    lbCompanyName.font = [UIFont systemFontOfSize:14];
    [lbCompanyName setTextColor:[UIColor blackColor]];
    [cell.contentView addSubview:lbCompanyName];
    [lbCompanyName release];
    
    //地址
    NSString *strRegionID = rowData[@"dcRegionId"];
    NSString *strCity = [CommonController getDictionaryDesc: [strRegionID substringToIndex:4] tableName:@"dcRegion"];
    NSString *strProvince = [CommonController getDictionaryDesc: [strRegionID substringToIndex:2] tableName:@"dcRegion"];
    UILabel *lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, lbCompanyName.frame.origin.y+lbCompanyName.frame.size.height + 5, 280, 20)];
    [lbAddress setText:[NSString stringWithFormat:@"%@%@%@", strProvince, strCity, rowData[@"Address"]]];
    lbAddress.font = [UIFont systemFontOfSize:14];
    [lbAddress setTextColor:[UIColor blackColor]];
    [cell.contentView addSubview:lbAddress];
    [lbAddress release];
    
    //查看简历
    UILabel *lbResume = [[UILabel alloc] initWithFrame:CGRectMake(20, lbAddress.frame.origin.y+lbAddress.frame.size.height, 280, 20)];
    [lbResume setText:[NSString stringWithFormat:@"查看简历：%@",rowData[@"cvName"]]];
    lbResume.font = [UIFont systemFontOfSize:11];
    [lbResume setTextColor:colorText];
    [cell.contentView addSubview:lbResume];
    [lbResume release];
    
    //查看时间
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(20,  lbResume.frame.origin.y+lbResume.frame.size.height, 200, 20)];
    NSString *strDate = [NSString stringWithFormat:@"查看时间：%@", [CommonController stringFromDate:[CommonController dateFromString:rowData[@"adddate"]] formatType:@"MM-dd HH:mm"]];
    [lbRefreshDate setText:strDate];
    [lbRefreshDate setFont:[UIFont systemFontOfSize:11]];
    [lbRefreshDate setTextColor:colorText];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];
    
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 90, 320, 0.5)];
    [viewSeparate setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:viewSeparate];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.jobListData[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperCpViewController *cpCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"SuperCpView"];
    cpCtrl.cpMainID= rowData[@"cpID"];
    cpCtrl.navigationItem.title = rowData[@"cpName"];
    UIViewController *superView = [CommonController getFatherController:self.view];
    [superView.navigationController pushViewController:cpCtrl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//选择简历
-(void) selectCV:(UIButton*) sender{
    UIImageView *imgCornor = sender.subviews[1];
    [self cancelDicPicker];
    imgCornor.image = [UIImage imageNamed:@"ico_triangle_orange.png"];
    
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithDictionary:self defaultArray:self.cvList defaultValue:@"0" defaultName:@"相关简历" pickerMode:DictionaryPickerModeOne] autorelease];
    self.DictionaryPicker.frame = CGRectMake(self.DictionaryPicker.frame.origin.x, self.DictionaryPicker.frame.origin.y-50, self.DictionaryPicker.frame.size.width, self.DictionaryPicker.frame.size.height);
    [self.DictionaryPicker setTag:1];
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    [self.DictionaryPicker showInView:pCtrl.view];
}

//获得简历列表
-(void) GetBasicCvList{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetBasicCvListByPaMainID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequestGetCvList = request;
    [dicParam release];
}


- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    switch (picker.tag) {
        case 1:
            if ([selectedValue isEqualToString:@"0"]) {
                [self.btnTop setTitle:@"相关简历" forState:UIControlStateNormal];
                selectCV = @"";
            }else{
                [self.btnTop setTitle:selectedName forState:UIControlStateNormal];
                selectCV = selectedValue;
            }
            
            [self onSearch];
            break;
        default:
            break;
    }
    [self cancelDicPicker];
}

- (void)dealloc {
    [_runningRequest release];
    [_isOnline release];
    [_tvJobList release];
    [_arrCheckJobID release];
    [_cPopup release];
    [_lbTop release];
    [_btnTop release];
    [super dealloc];
}
@end

