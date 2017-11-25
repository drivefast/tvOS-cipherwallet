//
//  VCCheckout.h
//  cwtv
//
//  Created by Radu Maierean on 11/14/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cipherwallet.h"

@interface VCCheckout : UIViewController {

    Cipherwallet *cw;

    IBOutlet UITextField *txtNumber;
    IBOutlet UITextField *txtName;
    IBOutlet UITextField *txtExpiration;
    IBOutlet UITextField *txtCCV;
    IBOutlet UITextField *txtZip;
    IBOutlet UIImageView *imgCWQR;

}

- (IBAction)submit;

- (void)resetForm;

@end

