//
//  CBCPCtrl.m
//  PushMGR
//
//  Created by Ole Andreas Torvmark on 3/16/12.
//  Copyright (c) 2012 ST alliance AS. All rights reserved.
//

#import "CBCPCtrl.h"

@implementation CBCPCtrl

@synthesize delegate;
@synthesize cBCP;


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    // So we now have done a services scan and it might have worked, or it might have failed.
    if (!error) {
        NSLog(@"Service discovery on peripheral : %@ UUID: %@ OK !", peripheral, peripheral.identifier);
        [self.delegate updateCPLog:[NSString stringWithFormat:@"Service discovery on peripheral : %@ UUID: %@ OK !", peripheral, peripheral.identifier]];
        int i = 0;
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"[%d] - Characteristic : %@ UUID: %@",i,characteristic,characteristic.UUID);
            [self.delegate updateCPLog:[NSString stringWithFormat:@"[%d] - Characteristic : %@ UUID: %@",i,characteristic,characteristic.UUID]];
            i++;
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // Not implemented in this tutorial

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    // Not implemented in this tutorial
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // So we now have done a services scan and it might have worked, or it might have failed.
    if (!error) {
        NSLog(@"Service discovery on peripheral : %@ UUID: %@ OK !", peripheral, peripheral.identifier);
        [self.delegate updateCPLog:[NSString stringWithFormat:@"Service discovery on peripheral : %@ UUID: %@ OK !", peripheral, peripheral.identifier]];
        
        int i = 0;
        for(CBService *service in peripheral.services) {
            NSLog(@"[%d] - Service : %@ UUID: %@",i, service, service.UUID);  
            [self.delegate updateCPLog:[NSString stringWithFormat:@"[%d] - Service : %@ UUID: %@",i, service, service.UUID]];
            [peripheral discoverCharacteristics:Nil forService:service];
            i++;
        }
    }
    else {
        NSLog(@"Service discovery on peripheral : %@ UUID: %@ Failed !", peripheral, peripheral.identifier);
        [self.delegate updateCPLog:[NSString stringWithFormat:@"Service discovery on peripheral : %@ UUID: %@ Failed !", peripheral, peripheral.identifier]];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        for ( CBService *service in peripheral.services ) {
            for ( CBCharacteristic *c in service.characteristics ) {
                if ( [c isEqual:characteristic] ) {
                    [self.delegate updatedCharacteristic:peripheral sUUID:service.UUID cUUID:c.UUID data:characteristic.value];
                }
            }
        }
    }
    else {
        NSLog(@"Error didUpdateValueForCharacteristic : %@",error);
        [self.delegate updateCPLog:[NSString stringWithFormat:@"Error didUpdateValueForCharacteristic : %@",error]];
        
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"peripheralDidUpdateRSSI");
    NSLog(@"RSSI : %d",peripheral.RSSI.intValue);
    [self.delegate updateCPLog:[NSString stringWithFormat:@"peripheralDidUpdateRSSI"]];
    [self.delegate updateCPLog:[NSString stringWithFormat:@"RSSI : %d",peripheral.RSSI.intValue]];
    [self.delegate updatedRSSI:peripheral];
}


-(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data {
    // Sends data to BLE peripheral to process HID and send EHIF command to PC
    NSLog(@"Sending %@ to peripheral",data);
    [self.delegate updateCPLog:[NSString stringWithFormat:@"Sending %@ to peripheral",data]];
    for ( CBService *service in peripheral.services ) {
        NSLog(@"Service %@",service.UUID);
        [self.delegate updateCPLog:[NSString stringWithFormat:@"Service %@",service.UUID]];
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                NSLog(@"Characteristic %@",characteristic.UUID);
                [self.delegate updateCPLog:[NSString stringWithFormat:@"Characteristic %@",characteristic.UUID]];
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    /* EVERYTHING IS FOUND, WRITE characteristic ! */
                    NSLog(@"Found Service, Characteristic, writing value");
                    [self.delegate updateCPLog:@"Found Service, Characteristic, writing value"];
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    
                }
            }
        }
    }
}

-(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID {
    NSLog(@"Reading from peripheral");
    [self.delegate updateCPLog:@"Reading from peripheral"];
    for ( CBService *service in peripheral.services ) {
        NSLog(@"Service %@",service.UUID);
        [self.delegate updateCPLog:[NSString stringWithFormat:@"Service %@",service.UUID]];
        if([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                NSLog(@"Charateristic %@",characteristic.UUID);
                [self.delegate updateCPLog:[NSString stringWithFormat:@"Characteristic %@",characteristic.UUID]];
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    /* Everything is found, read characteristic ! */
                    NSLog(@"Found Service,Characteristic, reading value");
                    [self.delegate updateCPLog:@"Found Service, Characteristic, reading value"];
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}

-(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable {
    NSLog(@"Setting notification for peripheral");
    [self.delegate updateCPLog:@"Setting notification for peripheral"];
    for ( CBService *service in peripheral.services ) {
        NSLog(@"Service %@",service.UUID);
        [self.delegate updateCPLog:[NSString stringWithFormat:@"Service %@",service.UUID]];
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                NSLog(@"Characteristic %@",characteristic.UUID);
                [self.delegate updateCPLog:[NSString stringWithFormat:@"Characteristic %@",characteristic.UUID]];
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]])
                {
                    /* Everything is found, set notification ! */
                    NSLog(@"Found Service,Characteristic, setting notification state");
                    [self.delegate updateCPLog:@"Found Service,Characteristic, setting notification state"];
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                    
                }
                
            }
        }
    }
}



@end
