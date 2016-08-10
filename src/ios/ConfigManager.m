//
//  ConfigManager.m
//  emission
//
//  Created by Kalyanaraman Shankari on 3/25/16.
//
//

#import "ConfigManager.h"
#import "BEMBuiltinUserCache.h"
#import "ConsentConfig.h"

#define SENSOR_CONFIG_KEY @"key.usercache.sensor_config"
#define CONSENT_CONFIG_KEY @"key.usercache.consent_config"

@implementation ConfigManager

static LocationTrackingConfig *_instance;

+ (LocationTrackingConfig*) instance {
    if (_instance == NULL) {
        _instance = [self readFromCache];
        if (_instance == NULL) {
            // This is still NULL, which means that there is no document in the usercache.
            // Let us add a dummy one based on the default settings
            // we don't want to save it to the database because then it will look like a user override
            _instance = [LocationTrackingConfig new];
        }
    }
    return _instance;
}

+ (LocationTrackingConfig*) readFromCache {
    return (LocationTrackingConfig*)[[BuiltinUserCache database] getDocument:SENSOR_CONFIG_KEY wrapperClass:[LocationTrackingConfig class]];
}

+ (void) updateConfig:(LocationTrackingConfig*) newConfig {
    [[BuiltinUserCache database] putReadWriteDocument:SENSOR_CONFIG_KEY value:newConfig];
    _instance = newConfig;
}

+ (BOOL) isConsented:(NSString*)reqConsent {
    ConsentConfig* currConfig = (ConsentConfig*)[[BuiltinUserCache database] getDocument:CONSENT_CONFIG_KEY wrapperClass:[ConsentConfig class]];
    if ([reqConsent isEqualToString:currConfig.approval_date]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void) setConsented:(ConsentConfig*)newConsent {
    [[BuiltinUserCache database] putReadWriteDocument:CONSENT_CONFIG_KEY value:newConsent];
}


@end