//
//  SubSiteViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-24.
//

#import "SubSiteViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"

@interface SubSiteViewController () <NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSArray *subsiteData;
@end

@implementation SubSiteViewController

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
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    
    [self onSearch];
}

- (void)onSearch
{
    [loadView startAnimating];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobListBySearch" Params:nil];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    self.subsiteData = requestData;
    [self.tvSubsite reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.subsiteData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.subsiteData[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"subsite"];
    cell.textLabel.text = rowData[@"SubSiteName"];
    cell.tag = [rowData[@"ID"] intValue];
    return cell;
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
    [_tvSubsite release];
    [super dealloc];
}
@end
