//
//  ViewController.m
//  AVAudioRecorderDemo
//
//  Created by weixu on 2017/3/8.
//  Copyright © 2017年 weixu. All rights reserved.
//

#import "ViewController.h"
#import "CustomAudioRecorder.h"

#define ALPHA  0.05
#define LOW_PASS 0.75

@interface ViewController () <CustomAudioRecorderDelegate>
@property (nonatomic, strong) CustomAudioRecorder *customAudioRecorder;
@property (weak, nonatomic) IBOutlet UIImageView *windmillImageView;
@property (nonatomic, assign) float currentAngle;
@property (nonatomic, assign) double filteredLowPass;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [self getSaveFilePath];
    
    self.customAudioRecorder = [[CustomAudioRecorder alloc] initWithPathUrl:path withSetting:nil];
    self.customAudioRecorder.delegare = self;
    
    self.filteredLowPass = 0.7;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/* 获取录音存放路径 */
- (NSString *)getSaveFilePath{
    NSString *urlStr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,YES).firstObject;
    urlStr = [urlStr stringByAppendingPathComponent:@"recorder.cef"];
    return urlStr;
}

- (IBAction)beginRecorder:(id)sender {
    [self.customAudioRecorder record];
}

- (IBAction)stopRecorder:(id)sender {
     [self.customAudioRecorder stopRecord];
}


- (void)onAveragePowerForChannel:(float)aVeragePower andChannel:(NSUInteger)channelNumber {
    
}

- (void)onPeakPowerForChannel:(float)aVeragePower andChannel:(NSUInteger)channelNumber {
    NSLog(@"averagePower = %f",aVeragePower);
    double peakPowerForChannel = pow(10,ALPHA * (double)aVeragePower);
    self.filteredLowPass = ALPHA * peakPowerForChannel + (1-ALPHA) * self.filteredLowPass;
    NSLog(@"filter = %f",self.filteredLowPass);
    // 過濾掉非吹氣的聲音，讀者們可以自行實驗這個範圍值
    if( self.filteredLowPass>LOW_PASS && self.filteredLowPass<1.0f ){
        // 旋轉風扇
        [self rotateFan:self.windmillImageView
                toAngle:(self.filteredLowPass-LOW_PASS)/(1-LOW_PASS)*2*M_PI];
    }
}

// 旋轉風扇
- (void) rotateFan:(UIImageView *) fanImage toAngle:(float) angle{
    [UIView beginAnimations:@"rotate_fan" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:5*angle/(2*M_PI)];
    //set point of rotation
    //fanImage.center = CGPointMake(170.0f , 240.0f);
    self.currentAngle+=angle;
    fanImage.transform =
    CGAffineTransformMakeRotation(self.currentAngle);
    [UIView commitAnimations];
}

- (void)onRecorderFinish {
    NSLog(@"onRecorderFinish");
}

- (void)onRecorderError {
    NSLog(@"onRecorderError");
}
@end
