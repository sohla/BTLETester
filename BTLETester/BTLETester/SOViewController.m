//
//  SOViewController.m
//  BTLETester
//
//  Created by Stephen OHara on 17/02/14.
//  Copyright (c) 2014 Stephen OHara. All rights reserved.
//

#import "SOViewController.h"

@interface SOViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;

@property CLLocationManager *locationManager;
@property (retain, nonatomic) CADisplayLink *displayLink;

@property NSMutableDictionary *rangedRegions;
@property NSMutableDictionary *beacons;


@end

@implementation SOViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.beacons = [[NSMutableDictionary alloc] init];

    
	// Do any additional setup after loading the view, typically from a nib.
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // Populate the regions we will range once.
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    NSArray *supportedProximityUUIDs = @[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"],
                                 [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
                                 [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"]];

    for (NSUUID *uuid in supportedProximityUUIDs)
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        self.rangedRegions[region] = [NSArray array];
    }

}

- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Start ranging when the view appears.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop ranging when the view goes away.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}

- (void)onDisplayLink:(id)sender {

}

#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{

    self.rangedRegions[region] = beacons;
    [self.beacons removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    
    NSSortDescriptor *rssiSD = [NSSortDescriptor sortDescriptorWithKey: @"rssi" ascending: NO];
    NSArray *closest = [allBeacons sortedArrayUsingDescriptors:@[rssiSD]];
    NSNumber *closestMinor = [[closest firstObject] valueForKey:@"minor"];
    
    if(closestMinor != NULL){

        self.minorLabel.text = [NSString stringWithFormat:@"%@",closestMinor];
        
        switch ([closestMinor shortValue]) {
            case 0:
                self.view.backgroundColor = [UIColor redColor];
                break;
            case 1:
                self.view.backgroundColor = [UIColor blueColor];
                break;
            case 2:
                self.view.backgroundColor = [UIColor greenColor];
                break;
            default:
                self.view.backgroundColor = [UIColor whiteColor];
        }
        
    }else{

        self.view.backgroundColor = [UIColor whiteColor];
        self.minorLabel.text = [NSString stringWithFormat:@"-"];

    }
    
 }


@end
