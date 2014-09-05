//
//  AboutUsViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-5.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@property (retain, nonatomic) IBOutlet UIWebView *viewWeb;

@end

@implementation AboutUsViewController

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
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* versionNum =[infoDict objectForKey:@"CFBundleVersion"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.qlrc.com/home/aboutus?strVersion=%@", versionNum]];
    [self.viewWeb loadRequest:[NSURLRequest requestWithURL:url]];
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
    [_viewWeb release];
    [super dealloc];
}
@end
