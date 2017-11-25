//
//  VCLogin.h
//  cwtv
//
//  Created by Radu Maierean on 11/14/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cipherwallet.h"

@interface VCLogin : UIViewController {

    Cipherwallet *cw;

    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UIImageView *imgCWQR;

}

- (IBAction)submit;

- (void)resetForm;

@end

