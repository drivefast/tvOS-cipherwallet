//
//  Cipherwallet.h
//  cwtv
//
//  Created by Radu Maierean on 11/16/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// These variables will point to the cipherwallet API implemented on your backend.
// (They only point to demo.cipherwallet.com for now as an example.)
// More information about the server side implementation here: https://www.cipherwallet.com/docs.html
// If you are using one of the cipherwallet SDKs, the resource names will be similar.
// You can find a few server-side SDKs here:
//      https://github.com/drivefast/pycipherwallet
//      https://github.com/drivefast/node-cipherwallet
//      https://github.com/drivefast/php-cipherwallet
#define API_URL @"https://demo.cipherwallet.com"
#define API_QRCODE_RESOURCE @"/cipherwallet/cw-qr.php"
#define API_POLL_RESOURCE @"/cipherwallet/cw-poll.php"

typedef enum CWService : NSUInteger {
    kCWServiceUndefined,
    kCWServiceCheckout,
    kCWServiceSignup,
    kCWServiceLogin
} CWService;

@interface Cipherwallet : NSObject {
    CWService cwService;
    NSString *cwServiceName;
    NSString *notificationName;
    BOOL polling;
    CGFloat pollingInterval;
}

@property (nonatomic) CWService cwService;
@property (nonatomic) NSString *cwServiceName;
@property (nonatomic) NSString *notificationName;
@property (nonatomic) BOOL polling;
@property (nonatomic) CGFloat pollingInterval;

- (id)initForService:(CWService)svc withName:(NSString *)name notify:(NSString *)notif;
- (void)setQRImageInView:(UIImageView *)imgView;

@end
