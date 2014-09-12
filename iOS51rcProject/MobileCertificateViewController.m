//
//  MobileCertificateViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-12.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "MobileCertificateViewController.h"

@interface MobileCertificateViewController ()

@end

@implementation MobileCertificateViewController

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
    // Do any additional setup after loading the view.
}

- (IBAction)confirmCertificate:(id)sender {
    
}

- (IBAction)sendSms:(id)sender {
    
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
    [_viewMobile release];
    [_btnSendSms release];
    [_txtMobile release];
    [_txtVerify release];
    [super dealloc];
}
@end
