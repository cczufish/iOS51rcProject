#import "ChatOnlineLogViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "SuperCpViewController.h"
#import  "Toast+UIView.h"

@interface ChatOnlineLogViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate, NSXMLParserDelegate, UITextFieldDelegate>
{
    NSMutableData *webData;
	NSString *currentElement;
    NSTimer *connectionTimer;  //timer对象
}
@property (retain, nonatomic) IBOutlet UIView *viewTop;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UITextField *textSend;
@property (retain, nonatomic) IBOutlet UIButton *btnSend;
@property (retain, nonatomic) IBOutlet UITableView *tvChatOnlineLogList;

@property (retain, nonatomic) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSMutableArray *chatOnlineLogData;
@end

@implementation ChatOnlineLogViewController
{
    LoadingAnimationView *loadView;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chatOnlineID = @"0";
    //代理(隐藏键盘)
    self.textSend.delegate = self;
    //顶部view边框
    self.viewTop.frame = CGRectMake(0, 60, 320, 40);
    self.viewTop.layer.backgroundColor = [UIColor colorWithRed:244.f/255.f green:244.f/255.f blue:244.f/255.f alpha:1].CGColor;
    self.viewTop.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.viewTop.layer.borderWidth = 0.5;
    //中间table的大小
    self.tvChatOnlineLogList.frame = CGRectMake(self.viewTop.frame.origin.x, self.viewTop.frame.origin.y+self.viewTop.frame.size.height, 320, self.view.frame.size.height - self.viewTop.frame.size.height - self.viewBottom.frame.size.height - 60);
    
    //公司名称和企业用户名称
    NSString *strTitle = [NSString stringWithFormat:@"%@  %@", self.cpName, self.caName];
    CGSize labelSize = [CommonController CalculateFrame:strTitle fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(240, 500)];
    int x = (320-labelSize.width)/2;
    UIButton *btnGoToCpPage = [[[UIButton alloc] initWithFrame:CGRectMake(x, 15, labelSize.width, 20)] autorelease];
    [btnGoToCpPage addTarget:self action:@selector(gotoCpPage) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lbCpName = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, labelSize.width, 15)] autorelease];
    lbCpName.font = [UIFont systemFontOfSize:14];
    lbCpName.text = strTitle;
    [btnGoToCpPage addSubview:lbCpName];
    [self.viewTop addSubview:btnGoToCpPage];
    
    //小图标
    UIImageView *imgOnline = [[[UIImageView alloc] initWithFrame:CGRectMake(btnGoToCpPage.frame.origin.x - 14, 13, 14, 16)] autorelease];
    if ([self.isOnline isEqualToString:@"1"] || [self.isOnline isEqualToString:@"true"]) {
        imgOnline.image = [UIImage imageNamed:@"ico_onlinechat_online.png"];
    }else{
        imgOnline.image = [UIImage imageNamed:@"ico_onlinechat_offline.png"];
    }
    [self.viewTop addSubview:imgOnline];

    //底部背景色
    self.viewBottom.layer.backgroundColor = [UIColor colorWithRed:244.f/255.f green:244.f/255.f blue:244.f/255.f alpha:1].CGColor;
    self.textSend.layer.cornerRadius = 5;
    self.btnSend.layer.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1].CGColor;
    
    //底部位置
    self.viewBottom.frame = CGRectMake(0, self.tvChatOnlineLogList.frame.origin.y + self.tvChatOnlineLogList.frame.size.height, 320, self.viewBottom.frame.size.height);
    
    //不显示列表分隔线
    self.tvChatOnlineLogList.separatorStyle = UITableViewCellSeparatorStyleNone;
    //获取数据
    [self getChatOnlineLog];
 
    //实例化timer，每隔7s刷新一下数据库
    connectionTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getChatOnlineLog) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:connectionTimer forMode:NSDefaultRunLoopMode];
}

//转到企业页面
-(void) gotoCpPage{
    UIStoryboard *jobSearchStoryboard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperCpViewController *cpMainCtrl = (SuperCpViewController*)[jobSearchStoryboard instantiateViewControllerWithIdentifier: @"SuperCpView"];
    cpMainCtrl.cpMainID = self.cpMainID;    
    [self.navigationController pushViewController:cpMainCtrl animated:true];
    cpMainCtrl.navigationItem.title = self.cpName;
}

//获取聊天记录
-(void) getChatOnlineLog{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    if (userID != nil) {
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:userID forKey:@"paMainID"];//21142013
        [dicParam setObject:code forKey:@"code"];//152014391908
        [dicParam setObject:self.cvMainID forKey:@"cvMainID"];
        [dicParam setObject:self.caMainID forKey:@"caMainID"];
        [dicParam setObject:@"1" forKey:@"isRead"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetChatMainByCvCaID" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 1;
        self.runningRequest = request;
        [dicParam release];
    }else{
        [connectionTimer invalidate];//其他操作，帐号已经退出了。停止计时器。
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) {
        [self.chatOnlineLogData removeAllObjects];
        self.chatOnlineLogData = requestData;
        //重新加载列表
        [self.tvChatOnlineLogList reloadData];
        //滚动到最下方
        [self.tvChatOnlineLogList scrollRectToVisible:CGRectMake(0, self.tvChatOnlineLogList.contentSize.height-1, 320, self.view.frame.size.height) animated:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatOnlineLogData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    NSDictionary *rowData = self.chatOnlineLogData[indexPath.row];
    
    int senderType = [rowData[@"SenderType"] integerValue];
    self.chatOnlineID = rowData[@"ChatOnlineID"];
    //企业发送
    if (senderType == 1) {
        //左侧图片
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 40, 40)]autorelease];
        imgView.image = [UIImage imageNamed:@"ico_onlinechat_cphead_online.png"];
        [cell.contentView addSubview:imgView];
        //消息内容View
        UIView *viewMsg = [[[UIView alloc] initWithFrame:CGRectMake(50, 8, 270, 60)] autorelease];
        viewMsg.layer.cornerRadius = 5;
        viewMsg.layer.backgroundColor = [UIColor colorWithRed:143.f/255.f green:202.f/255.f blue:221.f/255.f alpha:1].CGColor;
        //消息内容
        NSString *strMsg = rowData[@"Message"];
        CGSize labelSize = [CommonController CalculateFrame:strMsg fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(250, 500)];
        if (labelSize.width<80) {
            labelSize.width = 80;
        }
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        UILabel *lbMsg = [[[UILabel alloc] initWithFrame:CGRectMake(10, 5, labelSize.width, labelSize.height)] autorelease];
        [lbMsg setText:strMsg];
        lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
        lbMsg.numberOfLines = 0;
        [lbMsg setFont:[UIFont systemFontOfSize:12]];
        lbMsg.textColor = [UIColor whiteColor];
        [lbMsg setTextAlignment:NSTextAlignmentLeft];
        [viewMsg addSubview:lbMsg];
        //发送时间
        UILabel *lbRefreshDate = [[[UILabel alloc] initWithFrame:CGRectMake(lbMsg.frame.origin.x, lbMsg.frame.origin.y + lbMsg.frame.size.height + 5, 80, 15)] autorelease];
        NSString *strDate = [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"];
        [lbRefreshDate setText:strDate];
        [lbRefreshDate setFont:[UIFont systemFontOfSize:12]];
        [lbRefreshDate setTextColor:[UIColor whiteColor]];
        [lbRefreshDate setTextAlignment:NSTextAlignmentLeft];
        [viewMsg addSubview:lbRefreshDate];
        //重新设置消息内容的大小
        viewMsg.frame = CGRectMake(50, 8, labelSize.width + 10, labelSize.height + 15 + 10);
        [cell.contentView addSubview:viewMsg];        
    }else{
        //右侧图片
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(320-40-5, 8, 40, 40)]autorelease];
        imgView.image = [UIImage imageNamed:@"pic_pahead_default.png"];
        [cell.contentView addSubview:imgView];
        //消息内容View
        UIView *viewMsg = [[[UIView alloc] initWithFrame:CGRectMake(50, 8, 270, 60)] autorelease];
        viewMsg.layer.backgroundColor = [UIColor colorWithRed:190.f/255.f green:188.f/255.f blue:189.f/255.f alpha:1].CGColor;
        viewMsg.layer.cornerRadius = 5;
        //消息内容
        NSString *strMsg = rowData[@"Message"];
        CGSize labelSize = [CommonController CalculateFrame:strMsg fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(240, 500)];
        if (labelSize.width<80) {
            labelSize.width = 80;
        }
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        //最右端的坐标是320-50=270
        UILabel *lbMsg = [[[UILabel alloc] initWithFrame:CGRectMake(10, 5, labelSize.width + 10, labelSize.height)] autorelease];
        [lbMsg setText:strMsg];
        [lbMsg setFont:[UIFont systemFontOfSize:12]];
        lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
        lbMsg.numberOfLines = 0;
        lbMsg.textColor = [UIColor whiteColor];
        [lbMsg setTextAlignment:NSTextAlignmentLeft];
        [viewMsg addSubview:lbMsg];
        //发送时间
        UILabel *lbRefreshDate = [[[UILabel alloc] initWithFrame:CGRectMake(lbMsg.frame.origin.x, lbMsg.frame.origin.y + lbMsg.frame.size.height + 5, 80, 15)] autorelease];
        NSString *strDate = [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"];
        [lbRefreshDate setText:strDate];
        [lbRefreshDate setFont:[UIFont systemFontOfSize:12]];
        [lbRefreshDate setTextColor:[UIColor whiteColor]];
        [lbRefreshDate setTextAlignment:NSTextAlignmentLeft];
        [viewMsg addSubview:lbRefreshDate];
        
        //重新设置消息内容的大小
        viewMsg.frame = CGRectMake(270-labelSize.width - 20, 8, labelSize.width + 20, labelSize.height + 20 + 10);
        [cell.contentView addSubview:viewMsg];
    }

    //NSLog(@"%d",indexPath.row);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tmpDic = self.chatOnlineLogData[indexPath.row];
    NSString *strMsg = tmpDic[@"Message"];
     CGSize labelSize = [CommonController CalculateFrame:strMsg fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(250, 500)];
    if (labelSize.height>20) {
        return 42+ labelSize.height;
    }else{
        return 55;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//点击消息发送
- (IBAction)btnSendClick:(id)sender {
    NSString *strMsg = self.textSend.text;
    if ([strMsg isEqualToString:@""]) {
        [self.view makeToast:@"发送内容不能为空"];
        return;
    }
    
    [self textFieldShouldReturn:self.textSend];
    self.textSend.text = @"";
    
    if (self.chatOnlineID == nil) {
        self.chatOnlineID = @"0";
    }
    //注：调用的参数中枚举值必须使用具体的string，如 "<clientType>IOS</clientType>"，而不是"<clientType>1</clientType>"
    NSString *soapMessage = [NSString stringWithFormat:
							 @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
							 "<SOAP-ENV:Envelope \n"
							 "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" \n"
							 "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" \n"
							 "xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" \n"
							 "SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" \n"
							 "xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"> \n"
							 "<SOAP-ENV:Body> \n"
							 "<SendMessage xmlns=\"http://www.51rc.com/\">"
                             "<clientType>IOS</clientType>"
                             "<chatType>Pa2Cp</chatType>"
                             "<cvMainID>%@</cvMainID>"
                             "<caMainID>%@</caMainID>"
                             "<managerUserID>0</managerUserID>"
                             "<chatOnlineID>%@</chatOnlineID>"
                             "<msg>%@</msg>"
							 "</SendMessage> \n"
							 "</SOAP-ENV:Body> \n"
							 "</SOAP-ENV:Envelope>",
                             self.cvMainID, self.caMainID, self.chatOnlineID, strMsg];
    
	//[[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURL *url = [NSURL URLWithString:@"http://chat.51rc.com/ChatOnlineService.svc"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: @"http://www.51rc.com/ChatOnlineService/SendMessage" forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
    if(theConnection) {
        webData = [[NSMutableData data] retain];
    }
    else {
        NSLog(@"theConnection is NULL");
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[webData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	NSLog(@"Data has been loaded");
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:webData];
	[parser setDelegate:self];
    [parser parse];
	[webData release];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
               qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	currentElement = elementName;
}

//收到消息
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    NSLog(@"%@----%@",string,currentElement);
    if ([currentElement isEqualToString:@"SendMessageResult"] && [string isEqualToString:self.chatOnlineID])
    {
        //清空文本框
        self.textSend.text = @" ";
        //重新调用获取聊天消息，并显示在聊天框中
        [self getChatOnlineLog];
    }
}

//点击空白隐藏键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textSend resignFirstResponder];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    int offset = -240;
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)dealloc {
    if (connectionTimer != nil) {
        [connectionTimer invalidate];//把计时器停止
    }    
    [_chatOnlineID release];
    [_cvMainID release];
    [_caMainID release];
    [_cpName release];
    [_caName release];
    [_cpMainID release];
    [_isOnline release];
    [_viewBottom release];
    [_textSend release];
    [_btnSend release];
    [_viewTop release];    
    [super dealloc];
}
@end
