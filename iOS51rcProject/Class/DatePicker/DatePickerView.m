//
//  DatePickerView.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-18.
//

#import "DatePickerView.h"
#import "CommonController.h"

@implementation DatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCustom:(DatePickerType)dateType
           dateButton:(DatePickerButton)dateButton
              maxYear:(int)maxYear
              minYear:(int)minYear
           selectYear:(int)selectYear
             delegate:(id<DatePickerDelegate>)delegate
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"DatePickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.dateType = dateType;
        self.maxYear = maxYear;
        self.minYear = minYear;
        self.selectYear = selectYear;
        if (selectYear == 0) {
            self.selectYear = [[CommonController stringFromDate:[NSDate date] formatType:@"yyyy"] intValue];
        }
        self.dayCount = 31;
        if (dateButton == DatePickerWithReset) {
            [self.btnDateCancel setHidden:true];
            [self.btnDateReset setHidden:false];
        }
        else {
            [self.btnDateReset setHidden:true];
            [self.btnDateCancel setHidden:false];
        }
    }
    return self;
}

- (void)showDatePicker:(UIView *)view
{
    [view addSubview:self];
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    [self.pickerView selectRow:(self.selectYear-self.minYear) inComponent:0 animated:true];
}

- (void)canclDatePicker
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)datePickerClick:(id)sender {
    [self canclDatePicker];
    NSString *strSelectDate = nil;
    if (self.pickerView.numberOfComponents == 3) {
        strSelectDate = [NSString stringWithFormat:@"%d-%d-%d",(self.minYear+[self.pickerView selectedRowInComponent:0]),([self.pickerView selectedRowInComponent:1]+1),([self.pickerView selectedRowInComponent:2]+1)];
    }
    else {
        if ([self.pickerView selectedRowInComponent:1] < 9) {
            strSelectDate = [NSString stringWithFormat:@"%d年0%d月",(self.minYear+[self.pickerView selectedRowInComponent:0]),([self.pickerView selectedRowInComponent:1]+1)];
        }
        else {
            strSelectDate = [NSString stringWithFormat:@"%d年%d月",(self.minYear+[self.pickerView selectedRowInComponent:0]),([self.pickerView selectedRowInComponent:1]+1)];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(getSelectDate:)]) {
        [self.delegate getSelectDate:strSelectDate];
    }
}

- (IBAction)datePickerCancel:(id)sender {
    [self canclDatePicker];
}

- (IBAction)datePickerReset:(id)sender {
    [self canclDatePicker];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelPickDate)]) {
        [self.delegate cancelPickDate];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.dateType == DatePickerTypeDay) {
        return 3;
    }
    else {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return (self.maxYear-self.minYear+1);
            break;
        case 1:
            return 12;
            break;
        case 2:
            return self.dayCount;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [NSString stringWithFormat:@"%d年",(self.minYear+row)];
            break;
        case 1:
        {
            return [NSString stringWithFormat:@"%d月",(1+row)];
            break;
        }
        case 2:
            return [NSString stringWithFormat:@"%d日",(1+row)];
        default:
            return @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 1 && self.pickerView.numberOfComponents == 3) {
        if (row == 0 || row == 2 || row == 4 || row == 6 || row == 7 || row == 9 || row == 11) {
            self.dayCount = 31;
        }
        else {
            self.dayCount = 30;
        }
        [self.pickerView reloadComponent:2];
    }
}

- (void)dealloc {
    [_btnDateReset release];
    [_btnDateCancel release];
    [_pickerView release];
    [super dealloc];
}
@end
