//
//  ExperienceModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-19.
//

#import <UIKit/UIKit.h>
#import "touchScrollView.h"

@interface ExperienceModifyViewController : UIViewController
@property (retain, nonatomic) NSString *cvId;
@property (retain, nonatomic) NSString *cvExperienceId;
@property (retain, nonatomic) IBOutlet touchScrollView *scrollExperience;
@property (retain, nonatomic) IBOutlet UIView *viewExperience;
@property (retain, nonatomic) IBOutlet UITextField *txtCompany;
@property (retain, nonatomic) IBOutlet UIButton *btnIndustry;
@property (retain, nonatomic) IBOutlet UIButton *btnCompanySize;
@property (retain, nonatomic) IBOutlet UITextField *txtJobName;
@property (retain, nonatomic) IBOutlet UIButton *btnJobType;
@property (retain, nonatomic) IBOutlet UIButton *btnBeginDate;
@property (retain, nonatomic) IBOutlet UIButton *btnEndDate;
@property (retain, nonatomic) IBOutlet UIButton *btnLowerNumber;
@property (retain, nonatomic) IBOutlet UITextView *txtDescription;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;

@end
