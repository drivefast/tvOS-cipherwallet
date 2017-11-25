//
//  Cipherwallet.m
//  cwtv
//
//  Created by Radu Maierean on 11/16/17.
//  Copyright © 2017 Radu Maierean. All rights reserved.
//

#import "Cipherwallet.h"

@implementation Cipherwallet

@synthesize cwService;
@synthesize cwServiceName;
@synthesize notificationName;
@synthesize polling = _polling;
@synthesize pollingInterval;

- (id)init {
    if ((self = [super init])) {
        cwService = kCWServiceUndefined;
        cwServiceName = nil;
        _polling = NO;
        notificationName = nil;
        pollingInterval = 2000.;
    }
    return self;
}

- (id)initForService:(CWService)svc withName:(NSString *)name notify:(NSString *)notif {
    if ((self = [self init])) {
        cwService = svc;
        cwServiceName = [NSString stringWithString:name];
        notificationName = [NSString stringWithString:notif];
    }
    return self;
}

- (void)setQRImageInView:(UIImageView *)imgView {
// Request a QR code from your server. Your server must be able to return a valid image containing the QR code.
// More information about the server side implementation here: https://www.cipherwallet.com/docs.html

    NSAssert(cwService != kCWServiceUndefined, @"Cipherwallet service type is undefined");
    NSAssert(cwServiceName != nil, @"Cipherwallet service name is undefined");
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?tag=%@", API_URL, API_QRCODE_RESOURCE, cwServiceName];
    NSLog(@"requesting QR at %@", urlStr);
    NSURLSessionDownloadTask *qrTask = [[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:urlStr]
        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Internet connection error: %@", error.localizedDescription);
            } else {
                // The cipherwallet user-side client will loop polling your server, until data is delivered
                self.polling = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                });
            }
        }
    ];
    [qrTask resume];
}

- (BOOL)getPolling {
    return _polling;
}

- (void)setPolling:(BOOL)newValue {
// Initiate slow polling loop

    if (!newValue)
        _polling = NO;
    else {
        if (_polling) return;  // because we are already polling
        NSAssert(cwService != kCWServiceUndefined, @"Cipherwallet service type is undefined");
        NSAssert(cwServiceName != nil, @"Cipherwallet service name is undefined");
        NSAssert(notificationName != nil, @"Polling needs to generate a notification; the notification is not defined");
        // get the polling started
        _polling = YES;
        [self poll];
    }
}

- (void)delayedPoll {
// Poll again after a delay
    [self performSelector:@selector(poll) withObject:nil afterDelay:(pollingInterval / 1000.)];
}

- (void)poll {
// The cipherwallet user-side client sends a poll request to your server.
// More information about the server side implementation here: https://www.cipherwallet.com/docs.html

    if (!_polling) return;
    NSString *urlStr = [NSString stringWithFormat:@"%@%@?tag=%@", API_URL, API_POLL_RESOURCE, cwServiceName];
    NSURLSessionDataTask *pollTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr]
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *notificationData;
            if (error) {
                NSLog(@"Internet connection error: %@", error.localizedDescription);
                notificationData = [NSDictionary dictionaryWithObjectsAndKeys:error.localizedDescription, @"error", nil];
            } else {
                NSLog(@"polling at %@ returned status %ld", urlStr, (long)[(NSHTTPURLResponse *)response statusCode]);
                switch ([(NSHTTPURLResponse *)response statusCode]) {
                case 200: // results available; deJSONize them
                    notificationData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    break;
                case 202: // results not yet available; reschedule the poll in the main thread, after the polling period
                    [self performSelectorOnMainThread:@selector(delayedPoll) withObject:nil waitUntilDone:NO];
                    return; // right away, so we dont stop polling
                case 401: // unauthorized
                    notificationData = [NSDictionary dictionaryWithObjectsAndKeys:@"User not authorized", @"error", nil];
                    break;
                case 410: // session expired
                    notificationData = [NSDictionary dictionaryWithObjectsAndKeys:@"QR code expired", @"error", nil];
                    break;
                default:
                    notificationData = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"Server error %ld", (long)[(NSHTTPURLResponse *)response statusCode]], @"error",
                    nil];
                    break;
                }
            }
            // notify the interface and stop the polling
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:notificationData];
            });
            self.polling = NO;
        }
    ];
    [pollTask resume];

}

@end
