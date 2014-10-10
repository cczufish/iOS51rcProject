//
//  EducationModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-19.
//

#import "EducationModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "CvModifyViewController.h"
#import "DictionaryPickerView.h"
#import "DatePickerView.h"
#import "Toast+UIView.h"

@interface EducationModifyViewController () <NetWebServiceRequestDelegate,DictionaryPickerDelegate,UITextViewDelegate,DatePickerDelegate,UITextFieldDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) DictionaryPickerView *DictionaryPicker;
@property (nonatomic, retain) DatePickerView *datePicker;

@end

@implementation EducationModifyViewController

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
    self.viewEducation.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.viewEducation.layer.borderWidth = 1;
    self.viewEducation.layer.cornerRadius = 5;
    self.btnSave.layer.cornerRadius = 5;
    [self.scrollEducation setContentSize:CGSizeMake(320, 462)];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    if (![self.cvEducationId isEqualToString:@"0"]) {
        [self getCvInfo];
    }
}

- (IBAction)selectGraduationDate:(id)sender {
    [self cancelPicker];
    self.datePicker = [[DatePickerView alloc] initWithCustom:DatePickerTypeMonth dateButton:DatePickerWithoutReset maxYear:0 minYear:0 selectYear:0 delegate:self];
    [self.datePicker showDatePicker:self.view];
}

- (IBAction)selectDegree:(id)sender {
    [self cancelPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcEducation" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 1;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectEduType:(id)sender {
    [self cancelPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcEduType" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 2;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectMajor:(id)sender {
    [self cancelPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcMajor" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 3;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)saveEducation:(id)sender {
    [self cancelPicker];
    if (self.txtCollege.text.length == 0) {
        [self.view makeToast:@"请输入学校名称"];
        return;
    }
    if (self.btnGraduationDate.tag == 0) {
        [self.view makeToast:@"请选择毕业时间"];
        return;
    }
    if (self.btnDegree.tag == 0) {
        [self.view makeToast:@"请选择学历"];
        return;
    }
    if (self.btnEduType.tag == 0) {
        [self.view makeToast:@"请选择学历类型"];
        return;
    }
    if (self.btnMajor.tag == 0) {
        [self.view makeToast:@"请选择专业"];
        return;
    }
    if (self.txtMajor.text.length == 0) {
        [self.view makeToast:@"请输入专业名称"];
        return;
    }
    
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    [dicParam setObject:self.cvEducationId forKey:@"iD"];
    [dicParam setObject:self.txtCollege.text forKey:@"graduateCollage"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnGraduationDate.tag] forKey:@"graduation"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnMajor.tag] forKey:@"dcMajorID"];
    [dicParam setObject:self.txtMajor.text forKey:@"majorName"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnDegree.tag] forKey:@"degree"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnEduType.tag] forKey:@"eduType"];
    [dicParam setObject:self.txtDetails.text forKey:@"details"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateEducation" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self cancelPicker];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    switch (picker.tag) {
        case 1:
            //学历
            [self.btnDegree setTitle:selectedName forState:UIControlStateNormal];
            [self.btnDegree setTag:[selectedValue intValue]];
            break;
        case 2:
            //学历类型
            [self.btnEduType setTitle:selectedName forState:UIControlStateNormal];
            [self.btnEduType setTag:[selectedValue intValue]];
            break;
        case 3:
            //专业
            [self.btnMajor setTitle:selectedName forState:UIControlStateNormal];
            [self.btnMajor setTag:[selectedValue intValue]];
            break;
        default:
            break;
    }
    [self cancelPicker];
}

-(void)cancelPicker
{
    [self.view endEditing:true];
    
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
    [_DictionaryPicker release];
    
    [self.datePicker canclDatePicker];
    self.datePicker.delegate = nil;
    self.datePicker = nil;
    [_datePicker release];
}

- (void)getSelectDate:(NSString *)date
{
    [self.btnGraduationDate setTitle:date forState:UIControlStateNormal];
    NSString *strGraduation = [date stringByReplacingOccurrencesOfString:@"年" withString:@""];
    strGraduation = [strGraduation stringByReplacingOccurrencesOfString:@"月" withString:@""];
    [self.btnGraduationDate setTag:[strGraduation intValue]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self cancelPicker];
    if (textField.tag == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frameView = self.view.frame;
            CGRect frameText = [textField convertRect:textField.bounds toView:self.view];
            frameView.origin.y = 0-MIN(frameText.origin.y-62, 216);
            [self.view setFrame:frameView];
        }];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frameView = self.view.frame;
    frameView.origin.y = 0;
    [UIView animateWithDuration:0.1 animations:^{
        [self.view setFrame:frameView];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frameView = self.view.frame;
        CGRect frameText = [textView convertRect:textView.bounds toView:self.view];
        frameView.origin.y = 0-MIN(frameText.origin.y-62, 216);
        [self.view setFrame:frameView];
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect frameView = self.view.frame;
    frameView.origin.y = 0;
    [UIView animateWithDuration:0.1 animations:^{
        [self.view setFrame:frameView];
    }];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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
    NSArray *arrEducation = [self getArrayFromXml:xmlContent tableName:@"Table2"];
    NSDictionary *educationData = nil;
    for (NSDictionary *dicEducation in arrEducation) {
        if ([dicEducation[@"ID"] isEqualToString:self.cvEducationId]) {
            educationData = dicEducation;
            break;
        }
    }
    //学校
    [self.txtCollege setText:educationData[@"GraduateCollage"]];
    //毕业时间
    [self.btnGraduationDate setTitle:[NSString stringWithFormat:@"%@年%@月",[educationData[@"Graduation"] substringToIndex:4],[educationData[@"Graduation"] substringFromIndex:5]] forState:UIControlStateNormal];
    [self.btnGraduationDate setTag:[educationData[@"Graduation"] intValue]];
    //学历
    [self.btnDegree setTitle:educationData[@"Education"] forState:UIControlStateNormal];
    [self.btnDegree setTag:[educationData[@"Degree"] intValue]];
    //学历类型
    [self.btnEduType setTitle:educationData[@"EduTypeName"] forState:UIControlStateNormal];
    [self.btnEduType setTag:[educationData[@"EduType"] intValue]];
    //专业
    [self.btnMajor setTitle:educationData[@"Major"] forState:UIControlStateNormal];
    [self.btnMajor setTag:[educationData[@"dcMajorID"] intValue]];
    //专业名称
    [self.txtMajor setText:educationData[@"MajorName"]];
    //学习经历
    [self.txtDetails setText:educationData[@"Details"]];
    [loadView stopAnimating];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [loadView stopAnimating];
    CvModifyViewController *cvModifyC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    cvModifyC.toastType = 3;
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
    [_cvEducationId release];
    [loadView release];
    [_runningRequest release];
    [_DictionaryPicker release];
    [_userDefaults release];
    [_datePicker release];
    [_txtDetails release];
    [_txtCollege release];
    [_btnGraduationDate release];
    [_btnDegree release];
    [_btnEduType release];
    [_btnMajor release];
    [_txtMajor release];
    [_btnSave release];
    [_viewEducation release];
    [_scrollEducation release];
    [super dealloc];
}
@end
