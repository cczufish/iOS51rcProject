//
//  PaModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-17.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaModifyViewController : UIViewController
@property (retain, nonatomic) NSString *cvId;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollPa;
@property (retain, nonatomic) IBOutlet UIView *viewPa;
@property (retain, nonatomic) IBOutlet UITextField *txtName;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segGender;
@property (retain, nonatomic) IBOutlet UIButton *btnBirth;
@property (retain, nonatomic) IBOutlet UIButton *btnLivePlace;
@property (retain, nonatomic) IBOutlet UIButton *btnAccountPlace;
@property (retain, nonatomic) IBOutlet UIButton *btnGrowPlace;
@property (retain, nonatomic) IBOutlet UITextField *txtMobile;
@property (retain, nonatomic) IBOutlet UILabel *lbEmail;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;

@end
