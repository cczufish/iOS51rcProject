//
//  tipViewController.h
//  welcom_demo_1
//
//  Created by chaoxiao zhuang on 13-1-10.
//  Copyright (c) 2013年 taizhouxueyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController<UIScrollViewDelegate>
{
    
}

//@property(nonatomic,strong) UIImageView * indexView;
@property(nonatomic,strong) UIImageView * left;
@property(nonatomic,strong) UIImageView * right;

@property(retain,nonatomic) UIScrollView * pageScroll;
@property(retain,nonatomic) UIPageControl * pageControl;

@property(retain,nonatomic) UIButton * gotoMainViewBtn;
-(void)gotoMainView:(id)sender;

@end
