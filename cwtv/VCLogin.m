//
//  VCLogin.m
//  cwtv
//
//  Created by Radu Maierean on 11/14/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import "VCLogin.h"

@interface VCLogin ()

@end

@implementation VCLogin

- (void)viewDidLoad {
    [super viewDidLoad];
    // Wire up the cipherwallet class
    cw = [[Cipherwallet alloc] initForService:kCWServiceLogin withName:@"my_login" notify:@"LoginDataReceived"];
    // We will receive notifications on data received or any error events
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(codeScanned:) name:@"LoginDataReceived" object:nil
    ];
}

- (void)viewWillAppear:(BOOL)animated {
    [self resetForm];
}

- (void)resetForm {
// Acquire the QR code image; this will also get the polling started automatically
    if (!cw.polling) {
        imgCWQR.image = [UIImage imageNamed:@"qr_placeholder.png"];
        [cw setQRImageInView:imgCWQR];
    }
}

- (void)codeScanned:(NSNotification *)notification {
// If not an error, assume that the user authenticated successfully and proceed with executing this tvOS app as such
    NSDictionary *formData = (NSDictionary *)[notification object];
    if ([formData objectForKey:@"error"] && [(NSString *)[formData objectForKey:@"error"] length] ) {
        if ([[formData objectForKey:@"error"] isEqualToString:@"QR code expired"]) {
            imgCWQR.image = [UIImage imageNamed:@"qr_expired.png"];
        } else {
            imgCWQR.image = [UIImage imageNamed:@"qr_error.png"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"cipherwallet"
                message:[formData objectForKey:@"error"] preferredStyle:UIAlertControllerStyleAlert
            ];
            UIAlertAction* alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {}
            ];
            [alert addAction:alertAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        imgCWQR.image = [UIImage imageNamed:@"qr_done.png"];
        // here your tvOS application will have to move on as like the user had sucessfully authenticated.
        // For this particular example purposes, we will just show a successful confirmation screen.
        NSString *msg = [NSString stringWithFormat:@"Thank you, %@. Your login was successful.",
            (NSString *)[formData objectForKey:@"firstname"]
        ];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"cipherwallet"
            message:msg
            preferredStyle:UIAlertControllerStyleAlert
        ];
        UIAlertAction* alertAction = [UIAlertAction actionWithTitle:@"Yay!" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * action) {
                txtEmail.text = @"";
                txtPassword.text = @"";
                imgCWQR.image = [UIImage imageNamed:@"qr_placeholder.png"];
            }
        ];
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)submit {

}

@end
