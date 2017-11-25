//
//  VCSignup.h
//  cwtv
//
//  Created by Radu Maierean on 11/14/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cipherwallet.h"

@interface VCSignup : UIViewController {

    Cipherwallet *cw;

    IBOutlet UITextField *txtNameFirst;
    IBOutlet UITextField *txtNameLast;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPhone;
    IBOutlet UITextField *txtAge;
    IBOutlet UITextField *txtZip;
    IBOutlet UIImageView *imgCWQR;

}

- (IBAction)submit;

- (void)resetForm;

@end

