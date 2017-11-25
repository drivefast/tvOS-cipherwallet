//
//  VCSignup.m
//  cwtv
//
//  Created by Radu Maierean on 11/14/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import "VCSignup.h"

@interface VCSignup ()

@end

@implementation VCSignup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Wire up the cipherwallet class
    cw = [[Cipherwallet alloc] initForService:kCWServiceCheckout withName:@"my_signup" notify:@"SignupDataReceived"];
    // We will receive notifications on data received or any error events
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(codeScanned:) name:@"SignupDataReceived" object:nil
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
    "email": {"email":"jane.doe@example.com"},
    "phone": {"num":"8185551212", "cansms":false},
    "company": {"company":"The Happy Company", "position":"Marketing Specialist", "website":"http:\/\/example.com"},
    "name": {"first":"Jane", "last":"Doe"},
    "zip_code": {"street":"1234 Secure Lane", "street2":"", "city":"Happy", "state":"CA", "zip":"90210"},
    "birthday": {"birthdate":"January 1, 1995"}
}*/
        txtNameFirst.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"name"] objectForKey:@"first"];
        txtNameLast.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"name"] objectForKey:@"last"];
        txtEmail.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"email"] objectForKey:@"email"];
        txtPhone.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"phone"] objectForKey:@"num"];
        txtZip.text = (NSString *)[(NSDictionary *)[formData objectForKey:@"zip_code"] objectForKey:@"zip"];
        txtAge.text = [NSString stringWithFormat:@"%ld", [self ageFromBirthday:
            (NSString *)[(NSDictionary *)[formData objectForKey:@"birthday"] objectForKey:@"birthdate"]
        ]];
        imgCWQR.image = [UIImage imageNamed:@"qr_done.png"];
    }
}

- (NSUInteger)ageFromBirthday:(NSString *)bday {
// Helper function to calculate age from the birthday
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMMM dd, yyyy"];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
        components:NSCalendarUnitYear
        fromDate:[df dateFromString:bday] toDate:[NSDate date]
        options:0
    ];
    return [ageComponents year];
}

- (IBAction)submit {
// Call your API with the data on the form to register the user
// For example ourposes, we actually call the registration procedure of https://demo.cipherwallet.com
// Note that no validation of the received data is made - you may want to do that as well

    NSString *postData = [NSString stringWithFormat:@"firstname=%@&lastname=%@&email=%@&phone=%@&age=%@&zip=%@",
        txtNameFirst.text, txtNameLast.text, txtEmail.text, txtPhone.text, txtAge.text, txtZip.text
    ];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
        delegate:nil delegateQueue:[NSOperationQueue mainQueue]
    ];
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:
        [NSURL URLWithString:[NSString stringWithFormat:@"%@/signup-exec.php", API_URL]]
    ];
    [rq setHTTPMethod:@"POST"];
    [rq setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:rq
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Internet connection error: %@", error.localizedDescription);
            } else {
                NSLog(@"signup request %@ returned status %ld",
                    response.URL.description, (long)[(NSHTTPURLResponse *)response statusCode]
                );
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgCWQR.image = [UIImage imageNamed:@"qr_placeholder.png"];
                    // here your tvOS application will have to move on as like the user had entered the data manually,
                    // and the signup process would be completed. You would probably consider the user authenticated.
                    // For this particular example purposes, we will just show a successful confirmation screen.
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"cipherwallet"
                        message:@"Thank you. Your signup was successful. You may now log in to this application using cipherwallet."
                        preferredStyle:UIAlertControllerStyleAlert
                    ];
                    UIAlertAction* alertAction = [UIAlertAction actionWithTitle:@"Yay!" style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {}
                    ];
                    [alert addAction:alertAction];
                    [self presentViewController:alert animated:YES
                        completion: ^{
                            txtNameFirst.text = @"";
                            txtNameLast.text = @"";
                            txtEmail.text = @"";
                            txtPhone.text = @"";
                            txtZip.text = @"";
                            txtAge.text = @"";
                            imgCWQR.image = [UIImage imageNamed:@"qr_placeholder.png"];
                        }
                    ];
                });
            }
        }
    ];
    [task resume];

}

@end
