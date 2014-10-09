//
//  CreateResumeAlertViewController.m
//  iOS51rcProject
//
//  Created by qlrc on 14-8-21.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "CreateResumeAlertViewController.h"

@interface CreateResumeAlertViewController ()
@property (retain, nonatomic) IBOutlet UIButton *btnOK;
@property (retain, nonatomic) IBOutlet UIImageView *imgHasExp;
@property (retain, nonatomic) IBOutlet UIImageView *imgHasNoExp;

@end

@implementation CreateResumeAlertViewController

@synthesize delegate;
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
    hasExp = YES;
    self.view.layer.cornerRadius = 5;
    self.btnOK.layer.cornerRadius = 5;
    //[self createHasExpBtnGroupWithImage];
    // Do any additional setup after loading the view from its nib.
}
//点击确定
- (IBAction)btnOKClick:(id)sender {
    [delegate CreateResume:hasExp];
}
//点击有工作经验
- (IBAction)btnHasExpClick:(id)sender {
    self.imgHasExp.image = [UIImage imageNamed:@"radioChecked.png"];
    self.imgHasNoExp.image = [UIImage imageNamed:@"radioUnChecked.png"];
    hasExp = YES;
}

//点击没有工作经验
- (IBAction)btnHasNoExpClick:(id)sender {
    self.imgHasNoExp.image = [UIImage imageNamed:@"radioChecked.png"];
    self.imgHasExp.image = [UIImage imageNamed:@"radioUnChecked.png"];
    hasExp = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [_imgHasNoExp release];
    [_imgHasExp release];
    [_btnOK release];
    [super dealloc];
}
@end
