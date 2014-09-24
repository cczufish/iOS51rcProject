//
//  IntentionModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-18.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "IntentionModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "CvModifyViewController.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"

@interface IntentionModifyViewController ()<NetWebServiceRequestDelegate,DictionaryPickerDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) DictionaryPickerView *DictionaryPicker;
@property (nonatomic, retain) NSString *workPlaceId;
@property (nonatomic, retain) NSString *jobTypeId;

@end

@implementation IntentionModifyViewController

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
    self.viewIntention.layer.borderColor = [[UIColor grayColor] CGColor];
    self.viewIntention.layer.borderWidth = 1;
    self.viewIntention.layer.cornerRadius = 5;
    self.btnSave.layer.cornerRadius = 5;
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self getCvInfo];
}


- (IBAction)selectExperience:(id)sender {
    NSMutableArray *arrExperience = [[NSMutableArray alloc] initWithCapacity:10];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"0",@"id",
                              @"无工作经验",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"1",@"id",
                              @"1年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"2",@"id",
                              @"2年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"3",@"id",
                              @"3年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"4",@"id",
                              @"4年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"5",@"id",
                              @"5年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"6",@"id",
                              @"6年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"7",@"id",
                              @"7年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"8",@"id",
                              @"8年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"9",@"id",
                              @"9年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"10",@"id",
                              @"10年",@"value", nil] autorelease]];
    [arrExperience addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                              @"11",@"id",
                              @"10年以上",@"value", nil] autorelease]];
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithDictionary:self defaultArray:arrExperience defaultValue:@"" defaultName:@"" pickerMode:DictionaryPickerModeOne] autorelease];
    self.DictionaryPicker.tag = 1;
    [self.DictionaryPicker showInView:self.view];
    [arrExperience release];
}

- (IBAction)selectEmployType:(id)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"EmployType" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 2;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectSalary:(id)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcSalary" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 3;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectWorkPlace:(id)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL3 pickerMode:DictionaryPickerModeMulti pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.workPlaceId defaultName:self.btnWorkPlace.titleLabel.text] autorelease];
    self.DictionaryPicker.tag = 4;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectJobType:(id)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithJobType pickerMode:DictionaryPickerModeMulti pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.jobTypeId defaultName:self.btnJobType.titleLabel.text] autorelease];
    self.DictionaryPicker.tag = 5;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)changeNogetiation:(UIButton *)sender {
    if (sender.tag == 0) {
        self.btnNogetiation.tag = 1;
        [self.btnNogetiation setBackgroundImage:[UIImage imageNamed:@"chk_check.png"] forState:UIControlStateNormal];
    }
    else {
        self.btnNogetiation.tag = 0;
        [self.btnNogetiation setBackgroundImage:[UIImage imageNamed:@"chk_default.png"] forState:UIControlStateNormal];
    }
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    if (selectedValue.length == 0) {
        [self.view makeToast:@"此项未必选项"];
        return;
    }
    switch (picker.tag) {
        case 1:
            [self.btnExperience setTitle:selectedName forState:UIControlStateNormal];
            [self.btnExperience setTag:[selectedValue intValue]];
            break;
        case 2:
            [self.btnEmployType setTitle:selectedName forState:UIControlStateNormal];
            [self.btnEmployType setTag:[selectedValue intValue]];
            break;
        case 3:
            [self.btnSalary setTitle:selectedName forState:UIControlStateNormal];
            [self.btnSalary setTag:[selectedValue intValue]];
            break;
        case 4:
            [self.btnWorkPlace setTitle:selectedName forState:UIControlStateNormal];
            self.workPlaceId = [selectedValue stringByReplacingOccurrencesOfString:@"," withString:@" "];
            break;
        case 5:
            [self.btnJobType setTitle:selectedName forState:UIControlStateNormal];
            self.jobTypeId = [selectedValue stringByReplacingOccurrencesOfString:@"," withString:@" "];
            break;
        default:
            break;
    }
    [self cancelDicPicker];
}

-(void)cancelDicPicker
{
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
    [_DictionaryPicker release];
}

- (IBAction)saveIntention:(id)sender {
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnExperience.tag] forKey:@"relatedWorkYears"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnEmployType.tag] forKey:@"employType"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnSalary.tag] forKey:@"dcSalaryID"];
    [dicParam setObject:self.jobTypeId forKey:@"jobType"];
    [dicParam setObject:self.workPlaceId forKey:@"jobPlace"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnNogetiation.tag] forKey:@"isNegotiable"];
    [dicParam setObject:@"" forKey:@"industry"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateJobIntention" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

- (void)getCvInfo
{
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvInfo" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinishedFromCvInfo:(NetWebServiceRequest *)request
                          xmlContent:(GDataXMLDocument *)xmlContent;
{
    NSDictionary *intentionData = [self getArrayFromXml:xmlContent tableName:@"Table4"][0];
    if (intentionData[@"RelatedWorkYears"]) {
        //工作经验
        if ([intentionData[@"RelatedWorkYears"] isEqualToString:@"0"]) {
            [self.btnExperience setTitle:@"无" forState:UIControlStateNormal];
        }
        else if ([intentionData[@"RelatedWorkYears"] isEqualToString:@"11"]) {
            [self.btnExperience setTitle:@"10年以上" forState:UIControlStateNormal];
        }
        else {
            [self.btnExperience setTitle:[NSString stringWithFormat:@"%@年",intentionData[@"RelatedWorkYears"]] forState:UIControlStateNormal];
        }
        [self.btnExperience setTag:[intentionData[@"RelatedWorkYears"] intValue]];
        //薪水
        [self.btnSalary setTitle:intentionData[@"Salary"] forState:UIControlStateNormal];
        if ([intentionData[@"IsNegotiable"] isEqualToString:@"true"]) {
            self.btnNogetiation.tag = 1;
            [self.btnNogetiation setBackgroundImage:[UIImage imageNamed:@"chk_check.png"] forState:UIControlStateNormal];
        }
        else {
            self.btnNogetiation.tag = 0;
            [self.btnNogetiation setBackgroundImage:[UIImage imageNamed:@"chk_default.png"] forState:UIControlStateNormal];
        }
        [self.btnSalary setTag:[intentionData[@"dcSalaryID"] intValue]];
        //工作类型
        [self.btnEmployType setTitle:[CommonController getDictionaryDesc:intentionData[@"EmployType"] tableName:@"EmployType"] forState:UIControlStateNormal];
        [self.btnEmployType setTag:[intentionData[@"EmployType"] intValue]];
        //工作地点
        [self.btnWorkPlace setTitle:intentionData[@"JobPlaceName"] forState:UIControlStateNormal];
        self.workPlaceId = intentionData[@"JobPlace"];
        //职位类别
        [self.btnJobType setTitle:intentionData[@"JobTypeName"] forState:UIControlStateNormal];
        self.jobTypeId = intentionData[@"JobType"];
    }
    [loadView stopAnimating];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [loadView stopAnimating];
    CvModifyViewController *cvModifyC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    cvModifyC.toastType = 2;
    [self.navigationController popViewControllerAnimated:true];
}

//获取相关表数据
- (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName
{
    NSArray *xmlTable = [xmlContent nodesForXPath:[NSString stringWithFormat:@"//%@", tableName] error:nil];
    NSMutableArray *arrXml = [[[NSMutableArray alloc] init] autorelease];
    for (int i=0; i<xmlTable.count; i++) {
        GDataXMLElement *oneXmlElement = [xmlTable objectAtIndex:i];
        NSArray *arrChild = [oneXmlElement children];
        NSMutableDictionary *dicOneXml = [[NSMutableDictionary alloc] init];
        for (int j=0; j<arrChild.count; j++) {
            [dicOneXml setObject:[arrChild[j] stringValue] forKey:[arrChild[j] name]];
        }
        [arrXml addObject:dicOneXml];
        [dicOneXml release];
    }
    return arrXml;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self cancelDicPicker];
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
    [_cvId release];
    [loadView release];
    [_runningRequest release];
    [_DictionaryPicker release];
    [_userDefaults release];
    [_viewIntention release];
    [_btnExperience release];
    [_btnEmployType release];
    [_btnSalary release];
    [_btnWorkPlace release];
    [_btnJobType release];
    [_btnNogetiation release];
    [_btnSave release];
    [super dealloc];
}
@end
