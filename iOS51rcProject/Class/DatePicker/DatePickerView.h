//
//  DatePickerView.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-18.
//

#import <UIKit/UIKit.h>

typedef enum {
    DatePickerWithReset, //有重置按钮
    DatePickerWithoutReset //无重置按钮
} DatePickerButton;

typedef enum {
    DatePickerTypeDay, //年月日
    DatePickerTypeMonth //年月
} DatePickerType;

@protocol DatePickerDelegate <NSObject>
@required
- (void)getSelectDate:(NSString *)date;
@optional
- (void)cancelPickDate;
@end

@interface DatePickerView : UIView <UIPickerViewDataSource,UIPickerViewDelegate>
@property (assign, nonatomic) DatePickerButton dateButton;
@property (assign, nonatomic) DatePickerType dateType;
@property (assign, nonatomic) int maxYear;
@property (assign, nonatomic) int minYear;
@property (assign, nonatomic) int selectYear;
@property (assign, nonatomic) int dayCount;
@property (assign, nonatomic) id<DatePickerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *btnDateReset;
@property (retain, nonatomic) IBOutlet UIButton *btnDateCancel;
@property (retain, nonatomic) IBOutlet UIPickerView *pickerView;

- (id)initWithCustom:(DatePickerType)dateType
             dateButton:(DatePickerButton)dateButton
             maxYear:(int)maxYear
             minYear:(int)minYear
          selectYear:(int)selectYear
            delegate:(id<DatePickerDelegate>)delegate;
- (void)showDatePicker:(UIView *)view;
@end
