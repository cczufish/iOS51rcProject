//
//  SearchByKeyWorkViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-25.
//

#import "SearchByKeyWorkViewController.h"
#import "NetWebServiceRequest.h"
#import "SearchListViewController.h"
#import "Toast+UIView.h"
#import "FMDatabase.h"
#import "CommonController.h"

@interface SearchByKeyWorkViewController () <UITableViewDataSource,UITableViewDelegate,NetWebServiceRequestDelegate,UITextFieldDelegate>
@property (nonatomic, retain) NSMutableArray *keyWordListData;
@property (nonatomic, retain) NSMutableArray *historyListData;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;

@end

@implementation SearchByKeyWorkViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.txtKeyword];
    self.historyListData = [NSMutableArray arrayWithCapacity:10];
    [self getHistory];
}

- (void)getHistory
{
    FMResultSet *searchHistory = [CommonController querySql:@"SELECT KeyWords,JobNum FROM paSearchHistory WHERE LENGTH(KeyWords)>0 ORDER BY AddDate DESC LIMIT 0,10"];
    while ([searchHistory next]) {
        NSDictionary *dicHistory = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [searchHistory stringForColumn:@"KeyWords"],@"KeyWord",
                                    [searchHistory stringForColumn:@"JobNum"],@"SearchResult",nil];
        [self.historyListData addObject:dicHistory];
        [dicHistory release];
    }
    [searchHistory close];
    [self.tvKeyword reloadData];
}

- (void)textFieldTextDidChange:(id)sender
{
    if (self.txtKeyword.text.length == 0) {
        [self.keyWordListData removeAllObjects];
        [self.tvKeyword reloadData];
    }
    else {
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:self.txtKeyword.text forKey:@"strKey"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetKeywordListByKey" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
        [dicParam release];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [self.keyWordListData removeAllObjects];
    self.keyWordListData = [requestData mutableCopy];
    [self.tvKeyword reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.keyWordListData.count > 0) {
        return self.keyWordListData.count;
    }
    else {
        return self.historyListData.count+1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"keyword"] autorelease];
    NSDictionary *rowData = nil;
    if (self.keyWordListData.count > 0) {
        rowData = self.keyWordListData[indexPath.row];
    }
    else {
        if (indexPath.row == self.historyListData.count) {
            UIImageView *imgDelete = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 17, 20)];
            [imgDelete setImage:[UIImage imageNamed:@"ico_hiskeywords_del.png"]];
            [cell.contentView addSubview:imgDelete];
            [imgDelete release];
            
            UILabel *lbDelTitle = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 180, 30)];
            [lbDelTitle setFont:[UIFont systemFontOfSize:14]];
            [lbDelTitle setText:@"清空历史搜索记录"];
            [cell.contentView addSubview:lbDelTitle];
            [lbDelTitle release];
            return cell;
        }
        rowData = self.historyListData[indexPath.row];
    }
    UILabel *lbKeyword = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 200, 30)];
    [lbKeyword setFont:[UIFont systemFontOfSize:14]];
    [lbKeyword setText:rowData[@"KeyWord"]];
    [cell.contentView addSubview:lbKeyword];
    [lbKeyword release];
    
    UILabel *lbCount = [[UILabel alloc] initWithFrame:CGRectMake(225, 5, 90, 30)];
    [lbCount setFont:[UIFont systemFontOfSize:14]];
    [lbCount setTextAlignment:NSTextAlignmentRight];
    [lbCount setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
    [lbCount setText:[NSString stringWithFormat:@"%@个职位",rowData[@"SearchResult"]]];
    [cell.contentView addSubview:lbCount];
    [lbCount release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = nil;
    if (self.keyWordListData.count > 0) {
        rowData = self.keyWordListData[indexPath.row];
    }
    else {
        if (indexPath.row == self.historyListData.count) {
            [CommonController execSql:@"DELETE FROM paSearchHistory"];
            [self.historyListData removeAllObjects];
            [self.tvKeyword reloadData];
            return;
        }
        rowData = self.historyListData[indexPath.row];
    }
    self.txtKeyword.text = rowData[@"KeyWord"];
    [self goToSearch:nil];
}

- (IBAction)goToSearch:(id)sender
{
    [self.txtKeyword resignFirstResponder];
    if (self.txtKeyword.text.length == 0) {
        [self.view makeToast:@"请输入关键字"];
        return;
    }
    SearchListViewController *searchListC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchListView"];
    searchListC.searchKeyword = self.txtKeyword.text;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    searchListC.searchRegion = [userDefaults objectForKey:@"subSiteId"];
    searchListC.searchRegionName = [userDefaults objectForKey:@"subSiteCity"];
    searchListC.searchCondition = [NSString stringWithFormat:@"%@+%@",[userDefaults objectForKey:@"subSiteCity"],self.txtKeyword.text];
    [self.navigationController pushViewController:searchListC animated:true];
}

- (IBAction)clearTextField:(id)sender {
    self.txtKeyword.text = @"";
    [self.keyWordListData removeAllObjects];
    [self.tvKeyword reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.txtKeyword resignFirstResponder];
    return YES;
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
    [_keyWordListData release];
    [_tvKeyword release];
    [_txtKeyword release];
    [_runningRequest release];
    [super dealloc];
}
@end
