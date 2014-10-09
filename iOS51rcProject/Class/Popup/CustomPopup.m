#import "CustomPopup.h"
#import "CommonController.h"

@implementation CustomPopup
@synthesize delegate = _delegate;

-(id) popupCvSelect:(NSMutableArray *)arrayCv
{
    if (self = [super init]) {
        self.arrCvButton = [NSMutableArray arrayWithCapacity:3];
        self.buttonType = PopupButtonTypeNone;
        self.viewContent = [[[UIView alloc] init] autorelease];
        float contentHeight = 20;
        if (arrayCv.count > 1) {
            for (NSDictionary* dicCv in arrayCv) {
                UIButton *btnRadio = [[[UIButton alloc] initWithFrame:CGRectMake(20, contentHeight+5, 18, 18)] autorelease];
                [btnRadio setTitle:dicCv[@"ID"] forState:UIControlStateNormal];
                [btnRadio setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                if (self.selectCvID.length == 0) {
                    [btnRadio setImage:[UIImage imageNamed:@"radio_sel.png"] forState:UIControlStateNormal];
                    btnRadio.tag = 2;
                    self.selectCvID = dicCv[@"ID"];
                }
                else {
                    [btnRadio setImage:[UIImage imageNamed:@"radio_unsel.png"] forState:UIControlStateNormal];
                    btnRadio.tag = 1;
                }
                [btnRadio addTarget:self action:@selector(changeSelect:) forControlEvents:UIControlEventTouchUpInside];
                [self.viewContent addSubview:btnRadio];
                [self.arrCvButton addObject:btnRadio];
                
                UILabel *lbCvName = [[UILabel alloc] initWithFrame:CGRectMake(50, contentHeight, 200, 30)];
                [lbCvName setText:dicCv[@"Name"]];
                [lbCvName setFont:[UIFont systemFontOfSize:14]];
                [self.viewContent addSubview:lbCvName];
                [lbCvName release];
                contentHeight+=50;
            }
            UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(30, contentHeight, 80, 30)];
            [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
            [btnConfirm setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            btnConfirm.layer.cornerRadius = 5;
            [btnConfirm addTarget:self action:@selector(savePopup) forControlEvents:UIControlEventTouchUpInside];
            [self.viewContent addSubview:btnConfirm];
            [btnConfirm release];
            
            UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(130, contentHeight, 80, 30)];
            [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
            [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnCancel setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
            btnCancel.layer.cornerRadius = 5;
            [btnCancel addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
            [self.viewContent addSubview:btnCancel];
            [btnCancel release];
            
            contentHeight+=40;
        }
        [self.viewContent setFrame:CGRectMake(0, 0, 240, contentHeight)];
    }
    return self;
}

-(void) popUpRMAttend{
    
}

-(void) showJobApplyCvSelect:(NSString *)applyResult
                        view:(UIView *)view
{
    self.viewSuper = view;
    NSArray *arrResult = [applyResult componentsSeparatedByString:@"&"];
    if ([arrResult[0] isEqualToString:@"0"]) {
        //将uiview里的内容都删除，重新定高
        for (UIView *viewOne in self.viewContent.subviews) {
            [viewOne removeFromSuperview];
        }
        CGRect contentFrame = self.viewContent.frame;
        contentFrame.size.height = 75;
        self.viewContent.frame = contentFrame;
        //申请失败图片
        UIImageView *imgWarming = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
        [imgWarming setImage:[UIImage imageNamed:@"ico_jobapply_no.png"]];
        [self.viewContent addSubview:imgWarming];
        [imgWarming release];
        //申请失败标题
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(58, 12, 180, 30)];
        [lbTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [lbTitle setText:@"未能申请成功"];
        [self.viewContent addSubview:lbTitle];
        [lbTitle release];
        //申请失败原因
        UILabel *lbContent = [[UILabel alloc] initWithFrame:CGRectMake(12, 50, 223, 20)];
        [lbContent setText:@"职位已过期或您30天内已申请过该职位"];
        [lbContent setFont:[UIFont systemFontOfSize:13]];
        [self.viewContent addSubview:lbContent];
        [lbContent release];
        [self popupCommon:self.viewContent buttonType:PopupButtonTypeOK];
        [self showPopup:view];
    }
    else {
        int subviewsCount = self.viewContent.subviews.count;
        if (subviewsCount > 0) {
            [self.viewContent setFrame:CGRectMake(self.viewContent.frame.origin.x, self.viewContent.frame.origin.y, self.viewContent.frame.size.width, self.viewContent.frame.size.height+120)];
            for (UIView *viewOne in self.viewContent.subviews) {
                [viewOne setFrame:CGRectMake(viewOne.frame.origin.x, viewOne.frame.origin.y+120, viewOne.frame.size.width, viewOne.frame.size.height)];
            }
        }
        else {
            [self.viewContent setFrame:CGRectMake(self.viewContent.frame.origin.x, self.viewContent.frame.origin.y, self.viewContent.frame.size.width, self.viewContent.frame.size.height+60)];
        }
        //申请成功标题
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 160, 30)];
        NSString *strApplyResult = [NSString stringWithFormat:@"您成功申请了%@个职位",arrResult[0]];
        if (![arrResult[1] isEqualToString:@"0"]) {
            strApplyResult = [strApplyResult stringByAppendingFormat:@",失败%@个职位",arrResult[1]];
        }
        [lbTitle setText:strApplyResult];
        [lbTitle setFont:[UIFont systemFontOfSize:14]];
        [lbTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        CGSize labelSize = [CommonController CalculateFrame:strApplyResult fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(160, 5000)];
        CGRect titleRect = lbTitle.frame;
        titleRect.size = labelSize;
        lbTitle.frame = titleRect;
        lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
        lbTitle.numberOfLines = 0;
        [self.viewContent addSubview:lbTitle];
        [lbTitle release];
        
        //申请成功图片
        UIImageView *imgSuccess = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
        if (labelSize.height > 25) {
            [imgSuccess setFrame:CGRectMake(20, 30, 40, 40)];
        }
        [imgSuccess setImage:[UIImage imageNamed:@"ico_jobright.png"]];
        [self.viewContent addSubview:imgSuccess];
        [imgSuccess release];
        
        //申请成功后的提醒
        UILabel *lbTips = [[UILabel alloc] initWithFrame:CGRectMake(75, 25+labelSize.height, 160, 30)];
        [lbTips setText:@"平均申请15个职位可以换来一次面试机会"];
        [lbTips setFont:[UIFont systemFontOfSize:10]];
        [lbTips setTextColor:[UIColor grayColor]];
        lbTips.lineBreakMode = NSLineBreakByCharWrapping;
        lbTips.numberOfLines = 0;
        [self.viewContent addSubview:lbTips];
        [lbTips release];
        
        if (subviewsCount > 0) {
            //添加分割线
            UILabel *lbSeperate = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, 220, 1)];
            [lbSeperate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
            [self.viewContent addSubview:lbSeperate];
            [lbSeperate release];
            //添加选择简历提醒
            UILabel *lbCvTips = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 160, 20)];
            [lbCvTips setText:@"您可以重新选择应聘的简历"];
            [lbCvTips setFont:[UIFont systemFontOfSize:14]];
            [lbCvTips setTextColor:[UIColor grayColor]];
            [self.viewContent addSubview:lbCvTips];
            [lbCvTips release];
            [self popupCommon:self.viewContent buttonType:PopupButtonTypeNone];
            [self showPopup:view];
        }
        else {
            [self popupCommon:self.viewContent buttonType:PopupButtonTypeOK];
            [self showPopup:view];
        }
    }
}

-(void) changeSelect:(UIButton *)sender
{
    if (sender.tag == 1) {
        for (UIButton *btnCvRaido in self.arrCvButton) {
            [btnCvRaido setImage:[UIImage imageNamed:@"radio_unsel.png"] forState:UIControlStateNormal];
            btnCvRaido.tag = 1;
        }
        [sender setImage:[UIImage imageNamed:@"radio_sel.png"] forState:UIControlStateNormal];
        sender.tag = 2;
        self.selectCvID = sender.titleLabel.text;
    }
}

-(void) savePopup
{
    [self closePopup];
    [self.delegate getPopupValue:self.selectCvID];
}

-(id) popupCommon:(UIView *)contentView
       buttonType:(PopupButtonType)buttonType
{
    if (self = [super init]) {
        //加按钮
        [contentView setHidden:false];
        if (buttonType == PopupButtonTypeOK) {
            UIButton *btnOK = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2-contentView.frame.size.width/6, contentView.frame.size.height+15, contentView.frame.size.width/3, 30)];
            [btnOK setBackgroundColor:[UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:248.f/255.f alpha:1]];
            [btnOK setTitle:@"知道了" forState:UIControlStateNormal];
            [btnOK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnOK.titleLabel.font = [UIFont systemFontOfSize:14];
            btnOK.layer.cornerRadius = 5;
            btnOK.layer.borderWidth = 1;
            btnOK.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
            [btnOK addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
            CGRect innerFrame = contentView.frame;
            innerFrame.size.height = innerFrame.size.height+50;
            contentView.frame = innerFrame;
            [contentView addSubview:btnOK];
            [btnOK release];
        }
        else if (buttonType == PopupButtonTypeConfirmAndCancel) {
            UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2-contentView.frame.size.width/4-10, contentView.frame.size.height+15, contentView.frame.size.width/4, 30)];
            [btnConfirm setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
            [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnConfirm.titleLabel.font = [UIFont systemFontOfSize:14];
            btnConfirm.layer.cornerRadius = 5;
            [btnConfirm addTarget:self action:@selector(confirmAndCancelPopup) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:btnConfirm];
            [btnConfirm release];
            
            UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2+10, contentView.frame.size.height+15, contentView.frame.size.width/4, 30)];
            [btnCancel setBackgroundColor:[UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:248.f/255.f alpha:1]];
            [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
            [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
            btnCancel.layer.cornerRadius = 5;
            btnCancel.layer.borderWidth = 1;
            btnCancel.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
            [btnCancel addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:btnCancel];
            [btnCancel release];
            
            CGRect innerFrame = contentView.frame;
            innerFrame.size.height = innerFrame.size.height+50;
            contentView.frame = innerFrame;
        }
        self.viewContent = contentView;
    }
    return self;
}

-(void) showPopup:(UIView *)view
{
    self.viewSuper = view;
    [view popupView:self.viewContent];
}

-(void) closePopup
{
    [self.viewSuper closePopup];
    if (self.delegate && [self.delegate respondsToSelector:@selector(closePopupNext)]) {
        [self.delegate closePopupNext];
    }
}

-(void) confirmAndCancelPopup
{
    [self.viewSuper closePopup];
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmAndCancelPopupNext)]) {
        [self.delegate confirmAndCancelPopupNext];
    }
}

-(void) dealloc
{
    [_viewContent release];
    [_viewSuper release];
    [_arrCvButton release];
    [_selectCvID release];
    [super dealloc];
}

@end
