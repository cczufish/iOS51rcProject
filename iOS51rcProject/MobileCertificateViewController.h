//
//  MobileCertificateViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-12.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileCertificateViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *viewMobile;
@property (retain, nonatomic) IBOutlet UIButton *btnSendSms;
@property (retain, nonatomic) IBOutlet UITextField *txtMobile;
@property (retain, nonatomic) IBOutlet UITextField *txtVerify;

@end
