//
//  Reachability.h
//  WebViewObjC
//
//  Created by metanet on 2022/03/25.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

#pragma mark IPv6 Support

extern NSString *kReachabilityChangedNotification;

@interface Reachability : NSObject

+(instancetype)reachabilityWithHostName:(NSString *)hostName;

+(instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

+(instancetype)reachabilityForInternetConnection;

#pragma mark reachabilityForLocalWiFi

-(BOOL)startNotifier;
-(void)stopNotifier;

-(NetworkStatus)currentReachabilityStatus;

-(BOOL)connectionRequired;

@end


