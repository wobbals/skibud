//
//  ViewController.h
//  skibud
//
//  Created by Charley Robinson on 1/16/16.
//  Copyright © 2016 Wobbbals. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (readonly) IBOutlet UISwitch* masterPowerSwitch;
@property (readonly) IBOutlet UISwitch* waitTimesAnnounceSwitch;
@property (readonly) IBOutlet UISwitch* clockAnnounceSwitch;
@property (readonly) IBOutlet UILabel* altimeterLabel;

- (IBAction)masterPower:(id)sender;
- (IBAction)enableWaitTimesAnnounce:(id)sender;
- (IBAction)enableClockAnnounce:(id)sender;

@end

