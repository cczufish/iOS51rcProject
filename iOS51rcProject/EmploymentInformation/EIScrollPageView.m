#import "EIScrollPageView.h"
//#import "NetWebServiceRequest.h"

//滚动页面
@implementation EIScrollPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        mNeedUseDelegate = YES;
        [self commInit];
    }
    return self;
}

-(void)initData{
    [self freshContentTableAtIndex:0];
}


-(void)commInit{
    if (_contentPages == nil) {
        _contentPages = [[NSMutableArray alloc] init];
    }
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        NSLog(@"ScrollViewFrame:(%f,%f)",self.frame.size.width,self.frame.size.height);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    [self addSubview:_scrollView];
}

-(void)dealloc{
    [_contentPages removeAllObjects],[_contentPages release],_contentPages= nil;
    [_scrollView release];
    [super dealloc];
}

#pragma mark - 其他辅助功能
#pragma mark 添加ScrollowView子页面
-(void)setContentOfTables:(NSInteger)aNumerOfTables{
    for (int i = 0; i < aNumerOfTables; i++) {
        UITableView *vCustomTableView = [[UITableView alloc] initWithFrame:CGRectMake(320 * i, 0, 320, self.frame.size.height)];
        vCustomTableView.delegate = self;
        vCustomTableView.dataSource = self;
        //为table添加嵌套HeadderView
        //[self addLoopScrollowView:vCustomTableView];
        [_scrollView addSubview:vCustomTableView];
        [_contentPages addObject:vCustomTableView];
        [vCustomTableView release];
    }
    [_scrollView setContentSize:CGSizeMake(320 * aNumerOfTables, self.frame.size.height)];
}

#pragma mark 移动ScrollView到某个页面
-(void)moveScrollowViewAthIndex:(NSInteger)aIndex{
    mNeedUseDelegate = NO;
    CGRect vMoveRect = CGRectMake(self.frame.size.width * aIndex, 0, self.frame.size.width, self.frame.size.width);
    [_scrollView scrollRectToVisible:vMoveRect animated:YES];
    mCurrentPage= aIndex;
    //调用父页面的代理，父页面再调用自己的刷新事件
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)]) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex{
    if (_contentPages.count < aIndex) {
        return;
    }
    //重新绑定数据到某一个页面上
    UITableView *vTableContentView =(UITableView *)[_contentPages objectAtIndex:aIndex];
    //CustomTableView *vTableContentView =(CustomTableView *)[_contentPages objectAtIndex:aIndex];
    //[vTableContentView forceToFreshData];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    mNeedUseDelegate = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = (_scrollView.contentOffset.x+320/2.0) / 320;
    if (mCurrentPage == page) {
        return;
    }
    mCurrentPage= page;
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)] && mNeedUseDelegate) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        //        CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
        //        targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
        //        [self moveToTargetPosition:targetX];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"rmList"] autorelease];
    
//    NSDictionary *rowData = gRListData[indexPath.row];
//    
//    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, 55)];
//    tmpView.layer.borderWidth = 0.5;
//    tmpView.layer.borderColor = [UIColor grayColor].CGColor;
//    //显示标题
//    NSString *strTitle = rowData[@"Title"];
//    UIFont *titleFont = [UIFont systemFontOfSize:12];
//    CGFloat titleWidth = 245;
//    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
//    CGSize labelSize = [CommonController CalculateFrame:strTitle fontDemond:titleFont sizeDemand:titleSize];
//    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, labelSize.width, labelSize.height)];
//    lbTitle.text = strTitle;
//    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
//    lbTitle.numberOfLines = 0;
//    lbTitle.font = titleFont;
//    [tmpView addSubview:(lbTitle)];
//    [lbTitle release];
//    //来源
//    UILabel *lbAuthor = [[UILabel alloc] initWithFrame:CGRectMake(10, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 200, 15)];
//    lbAuthor.text = rowData[@"Author"];
//    lbAuthor.font = [UIFont systemFontOfSize:11];
//    lbAuthor.textColor = [UIColor grayColor];
//    [tmpView addSubview:(lbAuthor)];
//    [lbAuthor release];
//    //显示举办时间
//    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(220, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 80, 15)];
//    NSString *strDate = rowData[@"RefreshDate"];
//    NSDate *dtBeginDate = [CommonController dateFromString:strDate];
//    strDate = [CommonController stringFromDate:dtBeginDate formatType:@"MM-dd HH:mm"];
//    lbTime.text = strDate;
//    lbTime.textColor = [UIColor grayColor];
//    lbTime.font = [UIFont systemFontOfSize:11];
//    lbTime.textAlignment = NSTextAlignmentRight;
//    [tmpView addSubview:(lbTime)];
//    [lbTime release];
//    //New图片
//    NSDate *today = [NSDate date];
//    NSString *strToday = [CommonController stringFromDate:today formatType:@"yyyy-MM-dd"];
//    //today =[ CommonController dateFromString:strToday];
//    NSString *tmpDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd"];
//    //NSDate *dtEarly = [today earlierDate:dtBeginDate];
//    //if ([dtEarly isEqualToDate:today]) {
//    if ([strToday isEqualToString:tmpDate]) {
//        UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 30, 30)];
//        imgNew.image = [UIImage imageNamed:@"ico_jobnews_searchresult.png"];
//        [tmpView addSubview:imgNew];
//        [imgNew release];
//    }
//    
//    [cell.contentView addSubview:tmpView];
//    [tmpView autorelease];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
//    GRItemDetailsViewController *detailCtrl = (GRItemDetailsViewController*)[self.storyboard
//                                                                             instantiateViewControllerWithIdentifier: @"GRItemDetailsView"];
//    detailCtrl.strNewsID = gRListData[indexPath.row][@"ID"];
//    [self.navigationController pushViewController:detailCtrl animated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return [gRListData count];
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}
@end

