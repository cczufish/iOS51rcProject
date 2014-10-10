//
//  ExperienceModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-19.
//

#import "ExperienceModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "CvModifyViewController.h"
#import "DictionaryPickerView.h"
#import "DatePickerView.h"
#import "Toast+UIView.h"

@interface ExperienceModifyViewController ()<NetWebServiceRequestDelegate,DictionaryPickerDelegate,UITextViewDelegate,DatePickerDelegate,UITextFieldDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) DictionaryPickerView *DictionaryPicker;
@property (nonatomic, retain) DatePickerView *datePicker;

@end

@implementation ExperienceModifyViewController

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
    self.viewExperience.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.viewExperience.layer.borderWidth = 1;
    self.viewExperience.layer.cornerRadius = 5;
    self.btnSave.layer.cornerRadius = 5;
    [self.scrollExperience setContentSize:CGSizeMake(320, 550)];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    if (![self.cvExperienceId isEqualToString:@"0"]) {
        [self getCvInfo];
    }
}

- (IBAction)selectIndustry:(id)sender {
    [self cancelPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcIndustry" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 1;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectCompanySize:(id)sender {
    [self cancelPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcCompanySize" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 2;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectJobType:(id)sender {
    [self cancelPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithJobType pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerNoIncludeParent delegate:self defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 3;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectLowerNumber:(id)sender {
    [self cancelPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcLowerNumber" defaultValue:@"" defaultName:@""] autorelease];
    self.DictionaryPicker.tag = 4;
    [self.DictionaryPicker showInView:self.view];
}

- (IBAction)selectBeginDate:(id)sender {
    [self cancelPicker];
    self.datePicker = [[DatePickerView alloc] initWithCustom:DatePickerTypeMonth dateButton:DatePickerWithoutReset maxYear:0 minYear:0 selectYear:0 delegate:self];
    self.datePicker.tag = 1;
    [self.datePicker showDatePicker:self.view];
}

- (IBAction)selectEndDate:(id)sender {
    [self cancelPicker];
    self.datePicker = [[DatePickerView alloc] initWithCustom:DatePickerTypeMonth dateButton:DatePickerWithNow maxYear:0 minYear:0 selectYear:0 delegate:self];
    self.datePicker.tag = 2;
    [self.datePicker showDatePicker:self.view];
}

- (IBAction)saveExperience:(id)sender {
    [self cancelPicker];
    if (self.txtCompany.text.length == 0) {
        [self.view makeToast:@"请输入公司名称"];
        return;
    }
    if (self.btnIndustry.tag == 0) {
        [self.view makeToast:@"请选择行业"];
        return;
    }
    if (self.btnCompanySize.tag == 0) {
        [self.view makeToast:@"请选择公司规模"];
        return;
    }
    if (self.txtJobName.text.length == 0) {
        [self.view makeToast:@"请输入职位名称"];
        return;
    }
    if (self.btnJobType.tag == 0) {
        [self.view makeToast:@"请选择职位类别"];
        return;
    }
    if (self.btnBeginDate.tag == 0) {
        [self.view makeToast:@"请选择开始时间"];
        return;
    }
    if (self.btnEndDate.tag == 0) {
        [self.view makeToast:@"请选择结束时间"];
        return;
    }
    if (self.btnLowerNumber.tag == 0) {
        [self.view makeToast:@"请选择下属人数"];
        return;
    }
    if (self.btnBeginDate.tag > self.btnEndDate.tag) {
        [self.view makeToast:@"开始时间不能大于结束时间"];
        return;
    }
    if (self.txtDescription.text.length == 0) {
        [self.view makeToast:@"请输入工作描述"];
        return;
    }
    if (![loadView isAnimating]) {
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.cvId forKey:@"cvMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    [dicParam setObject:self.cvExperienceId forKey:@"iD"];
    [dicParam setObject:self.txtCompany.text forKey:@"companyName"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnIndustry.tag] forKey:@"dcIndustryID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnCompanySize.tag] forKey:@"dcCompanySizeID"];
    [dicParam setObject:self.txtJobName.text forKey:@"jobName"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnJobType.tag] forKey:@"dcJobtypeID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnBeginDate.tag] forKey:@"beginDate"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnEndDate.tag] forKey:@"endDate"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.btnLowerNumber.tag] forKey:@"subNodeNum"];
    [dicParam setObject:self.txtDescription.text forKey:@"description"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateExperience" Params:dicParam];
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
            //行业
            [self.btnIndustry setTitle:selectedName forState:UIControlStateNormal];
            [self.btnIndustry setTag:[selectedValue intValue]];
            break;
        case 2:
            //公司规模
            [self.btnCompanySize setTitle:selectedName forState:UIControlStateNormal];
            [self.btnCompanySize setTag:[selectedValue intValue]];
            break;
        case 3:
            //职位类别
            [self.btnJobType setTitle:selectedName forState:UIControlStateNormal];
            [self.btnJobType setTag:[selectedValue intValue]];
            break;
        case 4:
            //下属人数
            [self.btnLowerNumber setTitle:selectedName forState:UIControlStateNormal];
            [self.btnLowerNumber setTag:[selectedValue intValue]];
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
    if (self.datePicker.tag == 1) {
        [self.btnBeginDate setTitle:date forState:UIControlStateNormal];
        NSString *strBeginDate = [date stringByReplacingOccurrencesOfString:@"年" withString:@""];
        strBeginDate = [strBeginDate stringByReplacingOccurrencesOfString:@"月" withString:@""];
        [self.btnBeginDate setTag:[strBeginDate intValue]];
    }
    else if (self.datePicker.tag == 2) {
        if ([[date substringToIndex:4] isEqualToString:@"9999"]) {
            [self.btnEndDate setTitle:@"至今" forState:UIControlStateNormal];
        }
        else {
            [self.btnEndDate setTitle:date forState:UIControlStateNormal];
        }
        NSString *strEndDate = [date stringByReplacingOccurrencesOfString:@"年" withString:@""];
        strEndDate = [strEndDate stringByReplacingOccurrencesOfString:@"月" withString:@""];
        [self.btnEndDate setTag:[strEndDate intValue]];
    }
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
    NSArray *arrExperience = [self getArrayFromXml:xmlContent tableName:@"Table3"];
    NSDictionary *experienceData = nil;
    for (NSDictionary *dicExperience in arrExperience) {
        if ([dicExperience[@"ID"] isEqualToString:self.cvExperienceId]) {
            experienceData = dicExperience;
            break;
        }
    }
    //公司名称
    [self.txtCompany setText:experienceData[@"CompanyName"]];
    //开始时间
    [self.btnBeginDate setTitle:[NSString stringWithFormat:@"%@年%@月",[experienceData[@"BeginDate"] substringToIndex:4],[experienceData[@"BeginDate"] substringFromIndex:4]] forState:UIControlStateNormal];
    [self.btnBeginDate setTag:[experienceData[@"BeginDate"] intValue]];
    //结束时间
    if ([[experienceData[@"EndDate"] substringToIndex:4] isEqualToString:@"9999"]) {
        [self.btnEndDate setTitle:@"至今" forState:UIControlStateNormal];
    }
    else {
        [self.btnEndDate setTitle:[NSString stringWithFormat:@"%@年%@月",[experienceData[@"EndDate"] substringToIndex:4],[experienceData[@"EndDate"] substringFromIndex:4]] forState:UIControlStateNormal];
    }
    [self.btnEndDate setTag:[experienceData[@"EndDate"] intValue]];
    //行业
    [self.btnIndustry setTitle:experienceData[@"Industry"] forState:UIControlStateNormal];
    [self.btnIndustry setTag:[experienceData[@"dcIndustryID"] intValue]];
    //公司规模
    [self.btnCompanySize setTitle:experienceData[@"CpmpanySize"] forState:UIControlStateNormal];
    [self.btnCompanySize setTag:[experienceData[@"dcCompanySizeID"] intValue]];
    //职位类别
    [self.btnJobType setTitle:experienceData[@"JobType"] forState:UIControlStateNormal];
    [self.btnJobType setTag:[experienceData[@"dcJobtypeID"] intValue]];
    //下属人数
    [self.btnLowerNumber setTitle:experienceData[@"LowerNumber"] forState:UIControlStateNormal];
    [self.btnLowerNumber setTag:[experienceData[@"SubNodeNum"] intValue]];
    //职位名称
    [self.txtJobName setText:experienceData[@"JobName"]];
    //工作描述
    [self.txtDescription setText:experienceData[@"Description"]];
    [loadView stopAnimating];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [loadView stopAnimating];
    CvModifyViewController *cvModifyC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    cvModifyC.toastType = 4;
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
    [_cvExperienceId release];
    [_scrollExperience release];
    [_viewExperience release];
    [_txtCompany release];
    [_btnIndustry release];
    [_btnCompanySize release];
    [_txtJobName release];
    [_btnJobType release];
    [_btnBeginDate release];
    [_btnEndDate release];
    [_btnLowerNumber release];
    [_txtDescription release];
    [_btnSave release];
    [super dealloc];
}
@end
