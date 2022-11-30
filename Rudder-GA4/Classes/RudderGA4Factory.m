//
//  RudderAdjustFactory.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderGA4Factory.h"
#import "RudderGA4Integration.h"

@implementation RudderGA4Factory

static RudderGA4Factory *sharedInstance;

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (nonnull NSString *)key {
    return @"GA4";
}

- (nonnull id<RSIntegration>)initiate:(nonnull NSDictionary *)config client:(nonnull RSClient *)client rudderConfig:(nonnull RSConfig *)rudderConfig {
    [RSLogger logDebug:@"Creating RudderIntegrationFactory"];
    return [[RudderGA4Integration alloc] initWithConfig:config withAnalytics:client withRudderConfig:rudderConfig];
}

@end
