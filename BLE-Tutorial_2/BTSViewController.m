//
//  BTSViewController.m
//  PushMGR
//
//  Created by Ole Andreas Torvmark on 3/15/12.
//  Copyright (c) 2012 ST alliance AS. All rights reserved.
//

#import "BTSViewController.h"

@interface BTSViewController ()

@end

@implementation BTSViewController
@synthesize notifyCharacteristicButton;
@synthesize writeCharacteristicButton;
@synthesize readCharacteristicButton;
@synthesize RSSIBar;
@synthesize scanServicesButton;
@synthesize connectButton;
@synthesize scanButton;
@synthesize dbgText;
@synthesize window = _window;
@synthesize CBC;
@synthesize CBP;
@synthesize wasConnectedBeforBackground;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidEnterBackground:) 
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
 
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(applicationDidBecomeActive:) 
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Initializing BLE");
    [dbgText setText:[NSString stringWithFormat:@"%@Initializing BLE\r\n",dbgText.text]];
    self.CBC = [CBCMCtrl alloc];
    self.CBP = [CBCPCtrl alloc];
    if (self.CBC) {
        self.CBC.cBCM = [[CBCentralManager alloc] initWithDelegate:self.CBC queue:nil]; 
        self.CBC.delegate = self;
    }
    if (self.CBP) {
        self.CBP.delegate = self;
    }
    [RSSIBar setProgress: 0];

}
    
- (void)viewDidUnload
{
    NSLog(@"viewDidUnload");
    [self setScanButton:nil];
    [self setDbgText:nil];
    [self setConnectButton:nil];
    [self setScanServicesButton:nil];
    [self setRSSIBar:nil];
    [self setReadCharacteristicButton:nil];
    [self setWriteCharacteristicButton:nil];
    [self setNotifyCharacteristicButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void) applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    if (self.CBP.cBCP.state) {
        NSLog(@"Disconnecting from connected peripheral");
        self.wasConnectedBeforBackground = true;
        [self.CBC.cBCM cancelPeripheralConnection:self.CBP.cBCP];
    }
    else self.wasConnectedBeforBackground = false;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"applicationDidBecomeActive");
    if (self.wasConnectedBeforBackground) {
        NSLog(@"Was connected before, connecting again");
        [self.CBC.cBCM connectPeripheral:self.CBP.cBCP options:nil];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}
- (IBAction)scanButtonPress:(id)sender {
    if (self.CBC.cBReady) {
        // BLE HW is ready start scanning for peripherals now.
        NSLog(@"Button pressed, start scanning ...");
        [self.scanButton setTitle:@"Scanning ..." forState:UIControlStateNormal];
        [self.CBC.cBCM scanForPeripheralsWithServices:nil options:nil];
    }
}

- (IBAction)connectButtonPress:(id)sender {
    if(self.CBP.cBCP) {
        if(!self.CBP.cBCP.state) {
            [self.CBC.cBCM connectPeripheral:self.CBP.cBCP options:nil];
            [self.connectButton setTitle:@"Disconnect ..." forState:UIControlStateNormal];
        }
        else {
            [self.CBC.cBCM cancelPeripheralConnection:self.CBP.cBCP];
            [self.connectButton setTitle:@"Connect ..." forState:UIControlStateNormal];
        }
    }
}

- (void) updateCMLog:(NSString *)text {
    [dbgText setText:[NSString stringWithFormat:@"%@%@\r\n",dbgText.text,text]];
}

- (void) updateCPLog:(NSString *)text {
    [dbgText setText:[NSString stringWithFormat:@"%@%@\r\n",dbgText.text,text]];
}


- (void) foundPeripheral:(CBPeripheral *)p {
    [connectButton setEnabled:true];
    self.CBP.cBCP = p;
}

-(void) connectedPeripheral:(CBPeripheral *)p {
    [scanServicesButton setEnabled:true];
    [NSTimer scheduledTimerWithTimeInterval:(float)5.0 target:self selector:@selector(updateRSSITimer:) userInfo:nil repeats:NO];
    
    
}

-(void) servicesRead {
    
}

- (IBAction)scanServicesButtonPress:(id)sender {
    NSLog(@"Starting Service Scan !");
    [self.CBP.cBCP setDelegate:self.CBP];
    [self.CBP.cBCP discoverServices:nil];
}

-(void) updatedRSSI:(CBPeripheral *)peripheral {
    NSLog(@"RSSI updated : %d",peripheral.RSSI.intValue);
    int barValue = peripheral.RSSI.intValue;
    barValue +=100; 
    if (barValue > 100) barValue = 100;
    else if (barValue < 0) barValue = 0;
    [RSSIBar setProgress:(float)((float)barValue / (float)100)];
     
    //Trigger next round of measurements in 5 seconds :
    [NSTimer scheduledTimerWithTimeInterval:(float)5.0 target:self selector:@selector(updateRSSITimer:) userInfo:nil repeats:NO];
    
}

- (void) updateRSSITimer:(NSTimer *)timer {
    if (self.CBP.cBCP.state) {
        [self.CBP.cBCP readRSSI];
    }
}

-(void) updatedCharacteristic:(CBPeripheral *)peripheral sUUID:(CBUUID *)sUUID cUUID:(CBUUID *)cUUID data:(NSData *)data {
    NSLog(@"updatedCharacteristic in viewController");
    [self updateCMLog:@"updatedCharacteristic in viewController"];
    [self updateCMLog:[NSString stringWithFormat:@"Updated characteristic %@ - %@ | %@",sUUID,cUUID,data]];
    
}

- (IBAction)readCharacteristicButtonClick:(id)sender {
    [self.CBP readCharacteristic:self.CBP.cBCP sUUID:@"FFF0" cUUID:@"FFF2"];
    [self updateCMLog:@"Read value for FFF2 characteristic on FFF0 service"];
    
}
- (IBAction)writeCharacteristicClick:(id)sender {
    UInt16 j= 0004;
    NSData *formatedData = [[NSData alloc] initWithBytes:&j length:sizeof(j)];
    [self.CBP writeCharacteristic:self.CBP.cBCP sUUID:@"FFF0" cUUID:@"FFF2" data:formatedData];
    [self updateCMLog:@"writing value for FFF2 characteristic on FFF0 service"];
}
- (IBAction)notifyCharacteristicButtonClick:(id)sender {
    [self.CBP setNotificationForCharacteristic:self.CBP.cBCP sUUID:@"FFF0" cUUID:@"FFE2" enable:TRUE];
    [self updateCMLog:@"Set notification state for FFF1 characteristic on FFF0 service"];
}
@end
