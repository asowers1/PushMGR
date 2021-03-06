//
//  BTSViewController.h
//  PushMGR
//
//  Created by Ole Andreas Torvmark on 3/15/12.
//  Copyright (c) 2012 ST alliance AS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBCMCtrl.h"
#import "CBCPCtrl.h"

@interface BTSViewController : UIViewController <CBCMCtrlDelegate,CBCPCtrlDelegate>

@property (strong,nonatomic) UIWindow *window;
@property (strong,nonatomic) CBCMCtrl *CBC;
@property (strong,nonatomic) CBCPCtrl *CBP;
@property (nonatomic) boolean_t wasConnectedBeforBackground;


- (IBAction)scanButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UITextView *dbgText;
- (IBAction)connectButtonPress:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *scanServicesButton;
- (IBAction)scanServicesButtonPress:(id)sender;

- (void) applicationDidEnterBackground:(UIApplication *)application;
- (void) applicationDidBecomeActive:(UIApplication *)application;
@property (weak, nonatomic) IBOutlet UIProgressView *RSSIBar;

- (void) updateRSSITimer:(NSTimer *)timer; 

@property (strong, nonatomic) IBOutlet UIButton *readCharacteristicButton;
- (IBAction)readCharacteristicButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *writeCharacteristicButton;
- (IBAction)writeCharacteristicClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *notifyCharacteristicButton;
- (IBAction)notifyCharacteristicButtonClick:(id)sender;



@end
