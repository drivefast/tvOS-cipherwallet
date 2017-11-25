//
//  VCCheckout.m
//  cwtv
//
//  Created by Radu Maierean on 11/14/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import "VCCheckout.h"

@interface VCCheckout ()

@end

@implementation VCCheckout

- (void)viewDidLoad {
    [super viewDidLoad];
    // Wire up the cipherwallet class
    cw = [[Cipherwallet alloc] initForService:kCWServiceCheckout withName:@"my_checkout" notify:@"CheckoutDataReceived"];
    // We will receive notifications on data received or any error events
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(codeScanned:) name:@"CheckoutDataReceived" object:nil
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
// If not an error, dispatch the data received to the fields on the page
    NSDictionary *formData = (NSDictionary *)[notification object];
    if ([formData objectForKey:@"error"]) {
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
/* SAMPLE RESPONSE -- your API may return different data
{
    "creditcard": {
        "num":"5593099990528154",
        "name":"Jane Doe",
        "exp":"0119",
        "cvv":"123",
        "zip":"90210",
        "type":"Mastercard",
        "scanned":true
    }
    "name": {"first":"Jane", "last":"Doe"},
    "email": {"email":"jane.doe@example.com"},
    "phone": {"num":"8185551212", "cansms":false},
    "billto": {"street2":"", "state":"CA", "street":"1234 Secure Lane", "city":"Happy", "zip":"90210"},
}*/
        txtNumber.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"creditcard"] objectForKey:@"num"];
        txtName.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"creditcard"] objectForKey:@"name"];
        txtExpiration.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"creditcard"] objectForKey:@"exp"];
        txtCCV.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"creditcard"] objectForKey:@"cvv"];
        txtZip.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"creditcard"] objectForKey:@"zip"];
        imgCWQR.image = [UIImage imageNamed:@"qr_done.png"];
    }
}

- (IBAction)submit {
// You would insert the code that calls your API to transmit the payment information here
// For demo purposes, we just reset the form here, and acquire a new QR code
    txtNumber.text = @"";
    txtName.text = @"";
    txtExpiration.text = @"";
    txtCCV.text = @"";
    txtZip.text = @"";
    [self resetForm];
}

@end
