//
//  EducationModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-19.
//

#import <UIKit/UIKit.h>
#import "touchScrollView.h"

@interface EducationModifyViewController : UIViewController
@property (retain, nonatomic) NSString *cvId;
@property (retain, nonatomic) NSString *cvEducationId;
@property (retain, nonatomic) IBOutlet UITextView *txtDetails;
@property (retain, nonatomic) IBOutlet UITextField *txtCollege;
@property (retain, nonatomic) IBOutlet UIButton *btnGraduationDate;
@property (retain, nonatomic) IBOutlet UIButton *btnDegree;
@property (retain, nonatomic) IBOutlet UIButton *btnEduType;
@property (retain, nonatomic) IBOutlet UIButton *btnMajor;
@property (retain, nonatomic) IBOutlet UITextField *txtMajor;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
@property (retain, nonatomic) IBOutlet UIView *viewEducation;
@property (retain, nonatomic) IBOutlet touchScrollView *scrollEducation;

@end
