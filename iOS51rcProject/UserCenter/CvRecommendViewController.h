//
//  CvRecommendViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-22.
//

#import <UIKit/UIKit.h>

@interface CvRecommendViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *lbCv1;
@property (retain, nonatomic) IBOutlet UILabel *lbCv2;
@property (retain, nonatomic) IBOutlet UILabel *lbCv3;
@property (retain, nonatomic) IBOutlet UIButton *btnCv1;
@property (retain, nonatomic) IBOutlet UIButton *btnCv2;
@property (retain, nonatomic) IBOutlet UIButton *btnCv3;
@property (retain, nonatomic) IBOutlet UILabel *lbSwitch;
@property (retain, nonatomic) IBOutlet UIView *viewCvList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply1;
@property (retain, nonatomic) IBOutlet UIButton *btnApply2;
@property (retain, nonatomic) IBOutlet UIButton *btnApply3;
@property (retain, nonatomic) IBOutlet UIButton *btnFavorite;
@property (retain, nonatomic) IBOutlet UIView *viewOperate;
@property (retain, nonatomic) IBOutlet UIButton *btnCreate;
@property (retain, nonatomic) IBOutlet UIView *viewJobList1;
@property (retain, nonatomic) IBOutlet UIView *viewJobList2;
@property (retain, nonatomic) IBOutlet UIView *viewJobList3;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollContent;
@property (retain, nonatomic) IBOutlet UITableView *tvList1;
@property (retain, nonatomic) IBOutlet UITableView *tvList2;
@property (retain, nonatomic) IBOutlet UITableView *tvList3;
@property (retain, nonatomic) IBOutlet UIButton *btnModifyCv;

@end
