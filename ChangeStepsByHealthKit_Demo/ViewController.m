//
//  ViewController.m
//  ChangeStepsByHealthKit_Demo
//
//  Created by admin on 16/7/1.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) HKHealthStore *healthStore;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    self.textField.delegate = self;
    
    
    if ([HKHealthStore isHealthDataAvailable]) { //可以访问
        NSSet *writeDataTypes = [self dataTypesToWrite]; //写数据
        NSSet *readDataTypes = [self dataTypesToRead];//读数据
        
        self.healthStore = [[HKHealthStore alloc] init];
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"fail");
            }
        }];
    }

}


- (IBAction)healthAction:(UIButton *)sender {
    
    if (_textField.text && ![_textField.text isEqualToString:@""]) {
        [self recordWeight:[_textField.text doubleValue]];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入步数" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alert show];
    }

}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}


//写数据
- (NSSet *)dataTypesToWrite {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObject:stepType];
}
//读数据
- (NSSet *)dataTypesToRead {
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepType , nil];
}


//添加步数
-(void)recordWeight:(double)step{
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    if ([HKHealthStore isHealthDataAvailable] ) {
        HKQuantity *stepQuantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:step];
        HKQuantitySample *stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:stepQuantity startDate:[NSDate date] endDate:[NSDate date]];
        __block typeof(self) weakSelf = self;
        [self.healthStore saveObject:stepSample withCompletion:^(BOOL success, NSError *error) {
            if (success) {
                __block typeof(weakSelf) strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"步数已加上" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                    [alert show];
                    
                    strongSelf -> _textField.text = @"";
                });
                
                NSLog(@"The data has print");
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加步数失败" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
                [alert show];
                NSLog(@"The error is %@",error);
            }
        }];
    }
}








-(void)healthTest{
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    [healthStore requestAuthorizationToShareTypes:nil  readTypes:nil completion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
        });
        
    }];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
