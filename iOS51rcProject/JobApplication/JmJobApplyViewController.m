#import "JmJobApplyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "DictionaryPickerView.h"
#import "CustomPopup.h"
#import "JmMainViewController.h"
#import "MJRefresh.h"
#import "CommonController.h"
#import "SuperJobMainViewController.h"
#import "LoginViewController.h"
#import "Toast+UIView.h"

@interface JmJobApplyViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,DictionaryPickerDelegate,CustomPopupDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *cvList;
@property (nonatomic, retain) NSMutableArray *jobListData;
@property int pageNumber;
@property (nonatomic, retain) NSString *isOnline;
@property (retain, nonatomic) NSString *selectCV;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NetWebServiceRequest *runningRequestGetCvList;
@property (nonatomic, retain) CustomPopup *cPopup;
@property (retain, nonatomic) IBOutlet UILabel *lbTop;
@property (retain, nonatomic) IBOutlet UIButton *btnTop;
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;
@property BOOL boolChangeCv;
@end

@implementation JmJobApplyViewController
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
    self.lbTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lbTop.layer.borderWidth = 0.5;
    self.btnTop.titleLabel.text = @"相关简历";
    self.btnTop.titleLabel.font = [UIFont systemFontOfSize:14];
    self.btnTop.layer.borderWidth = 1;
    self.btnTop.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    
    [self.btnTop addTarget:self action:@selector(selectCV:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgCornor = [[[UIImageView alloc] initWithFrame:CGRectMake(65, 20, 10, 10)] autorelease];
    imgCornor.image = [UIImage imageNamed:@"ico_triangle.png"];
    [self.btnTop addSubview:imgCornor];
    
    self.pageNumber = 1;
    self.arrCheckJobID = [[NSMutableArray alloc] init];
    
    //设置底部功能栏
    //self.view.frame = CGRectMake(0, 0, 320, HEIGHT-170);
    self.tvJobList.frame = CGRectMake(0, self.tvJobList.frame.origin.y, 320, HEIGHT-self.viewBottom.frame.size.height-148);
    self.viewBottom.frame = CGRectMake(0, self.tvJobList.frame.origin.y+self.tvJobList.frame.size.height, 320, self.viewBottom.frame.size.height);
    self.viewBottom.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewBottom.layer.borderWidth = 1;
    self.btnDelete.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.btnDelete.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.btnDelete.layer.borderWidth = 1;
    self.btnDelete.layer.cornerRadius = 5;
    [self.btnDelete addTarget:self action:@selector(jobDelete) forControlEvents:UIControlEventTouchUpInside];
    
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self GetBasicCvList];
    self.selectCV = @"";
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
    [dicParam setObject:@"20" forKey:@"pageSize"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNum"];
    [dicParam setObject:self.selectCV forKey:@"cvMainID"];//21142013
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetExJobApply" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)footerRereshing{
    if (self.jobListData.count>0) {
        self.pageNumber++;
        [self onSearch];
    }     
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) { //职位搜索
        //清空所有子view
        for(UIView *view in [self.view subviews])
        {
            //只清除友好提示
            if (view.tag == 1) {
                [view removeFromSuperview];
            }
        }
        
        self.lbTop.text = @"申请职位的记录保存6个月";
        if (requestData.count>0 || (requestData.count == 0 && self.pageNumber > 1)) {
            //如果切换了简历，则清空joblistdata
            if (self.boolChangeCv == true) {
                [self.jobListData removeAllObjects];
                self.boolChangeCv = false;
            }
            
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
            [self.jobListData removeAllObjects];
            //没有面试通知记录
            self.lbTop.text = @" ";
            UIImageView *imgCornor = self.btnTop.subviews[1];
            imgCornor.image = [UIImage imageNamed:@"11111"];//赋空值
            self.btnTop.titleLabel.text = @" ";
            
            UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(20, 100, 240, 80)]autorelease];
            viewHsaNoCv.tag = 1;//清除用
            UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 40, 60)] autorelease];
            img.image = [UIImage imageNamed:@"pic_noinfo.png"];
            [viewHsaNoCv addSubview:img];
            
            UILabel *lb1 = [[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 220, 20)] autorelease];
            lb1.text = @"亲，没有申请职位记录，";
            lb1.font = [UIFont systemFontOfSize:14];
            lb1.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb1];
            
            UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(50, 30, 225, 20)] autorelease];
            lb2.text = @"现在就去申请感兴趣的职位吧！";
            lb2.font = [UIFont systemFontOfSize:14];
            lb2.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
            lb2.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb2];
            
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
    else if(request.tag == 6){
        UIViewController *pCtrl = [CommonController getFatherController:self.view];
        [pCtrl.view makeToast:@"删除成功"];
        //更新视图，删除全局对象内改数据，并重新绑定
        for (int i = 0; i<self.jobListData.count; i++) {
            NSDictionary *rowData = self.jobListData[i];
            NSString *jobID = rowData[@"JobID"];
            //如果包含在被删除的列表内，则删除
            for (int j=0; j<self.arrCheckJobID.count; j++) {
                if ([self.arrCheckJobID[j] isEqualToString:jobID]) {
                    [self.jobListData removeObjectAtIndex:i];
                    //break;
                }
            }
        }
        [self.tvJobList reloadData];
        self.arrCheckJobID = [[NSMutableArray alloc] init];
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
    
    //职位名称
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 160, 20)];
    [lbJobName setText:rowData[@"JobName"]];
    lbJobName.font = [UIFont systemFontOfSize:14];
    [lbJobName setTextColor:[UIColor blackColor]];
    [cell.contentView addSubview:lbJobName];
    [lbJobName release];
    
    //在线按钮
    BOOL isOnline = [rowData[@"IsOnline"] boolValue];
    if (isOnline) {
        UIButton *btnChat = [[[UIButton alloc] initWithFrame:CGRectMake(200, 5, 40, 20)] autorelease];
        [btnChat setImage:[UIImage imageNamed:@"ico_joblist_online.png"] forState:UIControlStateNormal];
        [cell.contentView addSubview:btnChat];
    }
    
    //匹配度
    UILabel *lbCvMatch = [[UILabel alloc] initWithFrame:CGRectMake(245, 10, 55, 15)];
    [lbCvMatch setText: [NSString stringWithFormat:@"匹配度%@%@", rowData[@"cvMatch"], @"%"]];
    lbCvMatch.font = [UIFont systemFontOfSize:10];
    [lbCvMatch setTextColor:[UIColor whiteColor]];
    lbCvMatch.textAlignment = NSTextAlignmentCenter;
    lbCvMatch.layer.cornerRadius = 5;
    lbCvMatch.layer.backgroundColor = [UIColor colorWithRed:9.f/255.f green:197.f/255.f blue:39.f/255.f alpha:1].CGColor;
    [cell.contentView addSubview:lbCvMatch];
    [lbCvMatch release];
    
    //公司名称
    UILabel *lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(40, lbJobName.frame.origin.y+lbJobName.frame.size.height, 280, 20)];
    [lbAddress setText:rowData[@"cpName"]];
    lbAddress.font = [UIFont systemFontOfSize:13];
    [lbAddress setTextColor:[UIColor grayColor]];
    [cell.contentView addSubview:lbAddress];
    [lbAddress release];
    
    //已经过期
    NSString *issueEnd = rowData[@"IssueEND"];
    NSDate *dtIssueEnd = [CommonController dateFromString:issueEnd];
    NSDate * now = [NSDate date];
    BOOL canBeDelete = false;
    if ([now laterDate:dtIssueEnd] == now ) {
        canBeDelete = true;
        UIImageView *imgEnd = [[[UIImageView alloc] initWithFrame:CGRectMake(290, 0, 30, 30)]autorelease];
        imgEnd.image = [UIImage imageNamed:@"ico_expire.png"];
        [cell.contentView addSubview:imgEnd];
    }

    //申请时间
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(40,  lbAddress.frame.origin.y+lbAddress.frame.size.height, 200, 20)];
    NSString *strDate = [NSString stringWithFormat:@"申请时间：%@", [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"]];
    [lbRefreshDate setText:strDate];
    [lbRefreshDate setFont:[UIFont systemFontOfSize:13]];
    [lbRefreshDate setTextColor:colorText];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];
    
    //复选框
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 77)];
    [btnCheck setTitle:rowData[@"JobID"] forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnCheck setTag:1];
    
    UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 20, 20)];
    [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
    [btnCheck addSubview:imgCheck];
    [imgCheck release];
    [cell.contentView addSubview:btnCheck];
    
    //查看状态
    UILabel *lbReply = [[UILabel alloc] initWithFrame:CGRectMake(220,  lbAddress.frame.origin.y+lbAddress.frame.size.height, 80, 20)];
    [lbReply setText:strDate];
    [lbReply setFont:[UIFont systemFontOfSize:12]];
    [lbReply setTextColor:[UIColor grayColor]];
    lbReply.textAlignment = NSTextAlignmentRight;
     [cell.contentView addSubview:lbReply];
    [lbReply release];

    int reply = [rowData[@"Reply"] integerValue];
    if (reply == 0) {
        NSString *strViewDate = rowData[@"ViewDate"];
        if (strViewDate == nil) {
             lbReply.text = @"未查看";
        }else{
            lbReply.text = @"已查看未答复";
        }
       //只有符合要求和不符合要求的职位可以删除，为查看的职位不可以删除.或者已经过期的也可以删除
    }else if(reply == 1){
        canBeDelete = true;
        lbReply.text = @"符合要求";
    }
    else if(reply == 2){
        canBeDelete = true;
        lbReply.text = @"不符合要求";
    }
    else if(reply == 3){
        canBeDelete = true;
        lbReply.text = @"以后联系";
    }
    else{
        canBeDelete = true;
        lbReply.text = @"系统回复";
    }
    //删除
    if (canBeDelete == true) {
        [btnCheck addTarget:self action:@selector(rowChecked:) forControlEvents:UIControlEventTouchUpInside];
    }
    [btnCheck release];
    
    //添加上拉加载更多
    [self.tvJobList addFooterWithTarget:self action:@selector(footerRereshing)];
    
    //分割线
    if (indexPath.row != self.jobListData.count - 1) {
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 76, 320, 1)];
        [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
        [cell.contentView addSubview:viewSeparate];
    }
    return cell;
}


//删除职位
- (void)jobDelete
{
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrCheckJobID.count == 0) {
            [pCtrl.view makeToast:@"您还没有选择职位"];
            return;
        }
        //＝＝＝＝＝＝＝＝＝弹出对话框，询问是否退出＝＝＝＝＝＝＝＝＝
        CGSize labelSize = CGSizeMake(240, 30);
        //添加view
        UIView *viewPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+20, labelSize.height+50)];
        //添加标题“提示”
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+10, 20)];
        [lbTitle setText:@"提示！"];
        [lbTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [lbTitle setTextAlignment:NSTextAlignmentCenter];
        //添加分割线
        UILabel *lbSeperate = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, labelSize.width, 1)];
        [lbSeperate setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        //消息内容
        NSString *strMsg = @"确定要删除选中的职位吗？";
        UILabel *lbMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, labelSize.width, labelSize.height)];
        [lbMsg setText: strMsg];
        [lbMsg setFont:[UIFont systemFontOfSize:14]];
        lbMsg.numberOfLines = 0;
        lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
        [viewPopup addSubview:lbMsg];
        [viewPopup addSubview:lbTitle];
        [viewPopup addSubview:lbSeperate];
        //显示
        self.cPopup = [[[CustomPopup alloc] popupCommon:viewPopup buttonType:PopupButtonTypeConfirmAndCancel] autorelease];
        self.cPopup.delegate = self;
        [self.cPopup showPopup:pCtrl.view];
        [lbMsg release];
        [lbTitle release];
        [lbSeperate release];
        [viewPopup release];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

//点击确定删除
- (void) confirmAndCancelPopupNext
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.arrCheckJobID componentsJoinedByString:@","] forKey:@"allIDs"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteExJobApplyBatch" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 6;
    self.runningRequest = request;
    [dicParam release];
    [loadView startAnimating];
}

- (void)rowChecked:(UIButton *)sender
{
    UIImageView *imgCheck = sender.subviews[0];
    if (sender.tag == 1) {
        if (![self.arrCheckJobID containsObject:sender.titleLabel.text]) {
            [self.arrCheckJobID addObject:sender.titleLabel.text];
        }
        [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
        [sender setTag:2];
    }
    else {
        [self.arrCheckJobID removeObject:sender.titleLabel.text];
        [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
        [sender setTag:1];
    }
    NSLog(@"%@",[self.arrCheckJobID componentsJoinedByString:@","]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

//打开职位页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.jobListData[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperJobMainViewController *jobCtrl =  [storyBoard instantiateViewControllerWithIdentifier:@"SuperJobMainView"];
    jobCtrl.cpMainID= rowData[@"cpID"];
    jobCtrl.JobID = rowData[@"JobID"];
    jobCtrl.navigationItem.title = rowData[@"cpName"];
    UIViewController *superView = [CommonController getFatherController:self.view];
    [superView.navigationController pushViewController:jobCtrl animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:false];
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
            self.boolChangeCv = true;
            if ([selectedValue isEqualToString:@"0"]) {
                [self.btnTop setTitle:@"相关简历" forState:UIControlStateNormal];
                self.selectCV = @"";
            }else{
                [self.btnTop setTitle:selectedName forState:UIControlStateNormal];
                self.selectCV = selectedValue;
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
    [_viewBottom release];
    [_btnDelete release];
    [super dealloc];
}
@end

