#import "EIListView.h"
#import "CommonController.h"
@implementation EIListView
@synthesize goToEIItemDetailsViewDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (_newsTableView == nil) {
            _newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            _newsTableView.delegate = self;
            _newsTableView.dataSource = self;
            [_newsTableView setBackgroundColor:[UIColor clearColor]];
        }
        if (self.eiListData == Nil) {
            self.eiListData = [[NSMutableArray alloc] init];
        }
        [self addSubview:_newsTableView];
    }
    
    //数据加载等待控件初始化
    //loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //开始等待动画
    //[loadView startAnimating];
    
    //添加上拉加载更多
    [self.newsTableView addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    page = 1;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    regionid = [userDefault objectForKey:@"subSiteId"];
    
    return self;
}

-(void)dealloc{   
    [_newsTableView release];
    [super dealloc];
}

#pragma mark 其他辅助功能
#pragma mark 强制列表刷新
-(void)forceToFreshData:(NSString *) newsType{
    self.newsType = newsType;
    if (page == 1) {
        [self.eiListData removeAllObjects];
        //[self.newsTableView reloadData];
    }
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:regionid forKey:@"dcRegionID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",page] forKey:@"pageNum"];
    [dicParam setObject:@"20" forKey:@"pageSize"];
    [dicParam setObject:self.newsType forKey:@"newsType"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetNewsListByNewsType" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

//绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"rmList"] autorelease];
    //数据
    NSDictionary *rowData = self.eiListData[indexPath.row];
    
    //显示标题
    NSString *strTitle = rowData[@"Title"];
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, 62)];
    tmpView.layer.borderWidth = 0.5;
    tmpView.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    
    UIFont *titleFont = [UIFont systemFontOfSize:13];
    CGFloat titleWidth = 300;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strTitle fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, labelSize.width, labelSize.height)];
    lbTitle.text = strTitle;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [tmpView addSubview:(lbTitle)];
    [lbTitle release];

    //来源
    NSString *strAuthor = rowData[@"Author"];
    UILabel *lbAuthor = [[UILabel alloc] initWithFrame:CGRectMake(10, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+10, 200, 15)];
    lbAuthor.text = strAuthor;
    lbAuthor.font = [UIFont systemFontOfSize:12];
    lbAuthor.textColor = [UIColor grayColor];
    [tmpView addSubview:(lbAuthor)];
    [lbAuthor release];

    NSString *strDate;
    if ([self.newsType  isEqual: @"0"])
        strDate = rowData[@"AnnounceDate"];
    else
        strDate = rowData[@"RefreshDate"];
    
    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(220, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+10, 80, 15)];
    NSDate *dtBeginDate = [CommonController dateFromString:strDate];
    strDate = [CommonController stringFromDate:dtBeginDate formatType:@"MM-dd HH:mm"];
    lbTime.text = strDate;
    lbTime.textColor = [UIColor grayColor];
    lbTime.font = [UIFont systemFontOfSize:13];
    lbTime.textAlignment = NSTextAlignmentRight;
    [tmpView addSubview:(lbTime)];
    [lbTime release];
    //如果是最新热点，则添加图片和文字
    if ([self.newsType  isEqual: @"0"])
    {
        //图片
        NSString *strImg = rowData[@"SmallImg"];
        UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(5, 52, 60, 60)];
        NSString *url = [NSString stringWithFormat:@"http://down.51rc.com/ImageFolder/operational/newsimage/%@",strImg];
        [self downLoadImage:true URL:url ImgView:imgNew];
        [tmpView addSubview:imgNew];
        [imgNew release];
         //文字
        NSString *strContent = [CommonController FilterHtml: rowData[@"Content"]];
        //去掉阅读提示这四个字
        strContent = [strContent stringByReplacingOccurrencesOfString:@"style=\"text-indent:2em\">" withString:@""];
        UILabel *lbContent = [[[UILabel alloc] initWithFrame:CGRectMake(70, 52, 230, 57)] autorelease];
        lbContent.text = strContent;
        lbContent.font = [UIFont systemFontOfSize:12];
        lbContent.lineBreakMode = NSLineBreakByCharWrapping;
        lbContent.numberOfLines = 0;
        [tmpView addSubview:lbContent];
        tmpView.frame = CGRectMake(5, 0, 310, 120);
    }
    [cell.contentView addSubview:tmpView];
    [tmpView autorelease];
    return cell;
}

//异步获取图片
- (void) downLoadImage:(BOOL)paramAnimated URL:(NSString *)imgURL ImgView:(UIImageView *) imgView{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        __block UIImage *image = nil;
        dispatch_sync(concurrentQueue, ^{
            /* Download the image here */
            NSString *urlAsString = imgURL;
            NSURL *url = [NSURL URLWithString:urlAsString];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            NSError *downloadError = nil;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:&downloadError];
            if (downloadError == nil && imageData != nil){
                image = [UIImage imageWithData:imageData]; /* We have the image. We can use it now */
            }
            else if (downloadError != nil){
                NSLog(@"Error happened = %@", downloadError);
            }
            else
            {
                NSLog(@"No data could get downloaded from the URL.");
            }
        });
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (image != nil){
                [imgView setImage:image];
                [imgView setContentMode:UIViewContentModeScaleAspectFit];
            } else {
                NSLog(@"Image isn't downloaded. Nothing to display.");
            }
        });
    });
} 

//选择某一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *newsID;
    if ([self.newsType isEqualToString:@"0"]) {
        newsID = self.eiListData[indexPath.row][@"Id"] ;
    }else
    {
        newsID = self.eiListData[indexPath.row][@"ID"] ;
    }
    [goToEIItemDetailsViewDelegate GoToEIItemDetailsView:newsID];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.eiListData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.newsType  isEqual: @"0"])
    {
        return 125;
    }else{
         return 65;
    }   
}

- (void)footerRereshing{
    page++;
    [self forceToFreshData:self.newsType];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) {
        if(page == 1){
            [self.eiListData removeAllObjects];
            self.eiListData = requestData;
        }
        else{
            [self.eiListData addObjectsFromArray:requestData];
        }
        
        [self.newsTableView reloadData];
        [self.newsTableView footerEndRefreshing];
        
        //结束等待动画
        //[loadView stopAnimating];
    }
}

@end

