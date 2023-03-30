//
//  RudderAdjustIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderGA4Integration.h"
#import "RudderGA4Utils.h"

@implementation RudderGA4Integration

#pragma mark - Initialization

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(nonnull RSClient *)client  withRudderConfig:(nonnull RSConfig *)rudderConfig {
    self = [super init];
    if (self) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ([FIRApp defaultApp] == nil){
                [FIRApp configure];
                [RSLogger  logDebug:@"Rudder-Firebase is initialized"];
            } else {
                [RSLogger  logDebug:@"Firebase core already initialized - skipping on Rudder-Firebase"];
            }
        });
    }
    return self;
}

- (void)dump:(RSMessage *)message {
    if (message != nil) {
        [self processRudderEvent:message];
    }
}

- (void) processRudderEvent: (nonnull RSMessage *) message {
    NSString *type = message.type;
    if (type != nil) {
        if ([type  isEqualToString: @"identify"]) {
            NSString *userId = message.userId;
            if (![RudderGA4Utils isEmpty:userId]) {
                [RSLogger logDebug:@"Setting userId to firebase"];
                [FIRAnalytics setUserID:userId];
            }
            NSDictionary *traits = message.context.traits;
            if (traits != nil) {
                for (NSString *key in [traits keyEnumerator]) {
                    if([key isEqualToString:@"userId"]) continue;
                    NSString* firebaseKey = [RudderGA4Utils getTrimKey:key];
                    if (![IDENTIFY_RESERVED_KEYWORDS_GA4 containsObject:firebaseKey]) {
                        [RSLogger logDebug:[NSString stringWithFormat:@"Setting userProperty to Firebase: %@", firebaseKey]];
                        [FIRAnalytics setUserPropertyString:traits[key] forName:firebaseKey];
                    }
                }
            }
        } else if ([type isEqualToString:@"screen"]) {
            NSString *screenName = message.event;
            if ([RudderGA4Utils isEmpty:screenName]) {
                [RSLogger logDebug:@"Since the event name is not present, the screen event sent to GA4 has been dropped."];
                return;
            }
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setValue:screenName forKey:kFIRParameterScreenName];
            [self attachAllCustomProperties:params properties:message.properties];
            [FIRAnalytics logEventWithName:kFIREventScreenView parameters:params];
        } else if ([type isEqualToString:@"track"]) {
            NSString *eventName = message.event;
            if ([RudderGA4Utils isEmpty:eventName]) {
                [RSLogger logDebug:@"Since the event name is not present, the track event sent to GA4 has been dropped."];
                return;
            }
            if ([eventName isEqualToString:@"Application Opened"]) {
                [self handleApplicationOpenedEvent:message.properties];
            }
            else if (ECOMMERCE_EVENTS_MAPPING_GA4[eventName]){
                [self handleECommerceEvent:eventName properties:message.properties];
            }
            else {
                [self handleCustomEvent:eventName properties:message.properties];
            }
        } else {
            [RSLogger logWarn:@"Message type is not recognized"];
        }
    }
}

-(void) handleApplicationOpenedEvent: (NSDictionary *) properties  {
    NSString *firebaseEvent = kFIREventAppOpen;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [self makeFirebaseEvent: firebaseEvent params:params properties:properties];
}

-(void) handleECommerceEvent: (NSString *) eventName properties: (NSDictionary *) properties {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *firebaseEvent = ECOMMERCE_EVENTS_MAPPING_GA4[eventName];
    if (![RudderGA4Utils isEmpty:properties]) {
        if ([firebaseEvent isEqualToString:kFIREventShare]) {
            if (![RudderGA4Utils isEmpty:properties[@"cart_id"]]) {
                [params setValue:properties[@"cart_id"] forKey:kFIRParameterItemID];
            } else if (![RudderGA4Utils isEmpty:properties[@"product_id"]]) {
                [params setValue:properties[@"product_id"] forKey:kFIRParameterItemID];
            }
        }
        if ([firebaseEvent isEqualToString:kFIREventViewPromotion] || [firebaseEvent isEqualToString:kFIREventSelectPromotion]) {
            if (![RudderGA4Utils isEmpty:properties[@"name"]]) {
                [params setValue:properties[@"name"] forKey:kFIRParameterPromotionName];
            }
        }
        if ([firebaseEvent isEqualToString:kFIREventSelectContent]) {
            if (![RudderGA4Utils isEmpty:properties[@"product_id"]]) {
                [params setValue:properties[@"product_id"] forKey:kFIRParameterItemID];
            }
            [params setValue:@"product" forKey:kFIRParameterContentType];
        }
        [self addConstantParamsForECommerceEvent:params eventName:eventName];
        [self handleECommerceEventProperties:params properties:properties firebaseEvent:firebaseEvent];
    }
    [self makeFirebaseEvent:firebaseEvent params:params properties:properties];
}

-(void) addConstantParamsForECommerceEvent:(NSMutableDictionary *) params eventName:(NSString *) eventName {
    if ([eventName isEqualToString:ECommProductShared]) {
        [params setValue:@"product" forKey:kFIRParameterContentType];
    } else if ([eventName isEqualToString:ECommCartShared]) {
        [params setValue:@"cart" forKey:kFIRParameterContentType];
    }
}

-(void) handleCustomEvent: (NSString *) eventName properties: (NSDictionary *) properties {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *firebaseEvent = [RudderGA4Utils getTrimKey:eventName];
    [self makeFirebaseEvent:firebaseEvent params:params properties:properties];
}

-(void) makeFirebaseEvent:(NSString *) firebaseEvent params:(NSMutableDictionary *) params properties: (NSDictionary *) properties {
    [self attachAllCustomProperties:params properties:properties];
    [RSLogger logDebug:[NSString stringWithFormat:@"Logged \"%@\" to Firebase with properties: %@", firebaseEvent, properties]];
    [FIRAnalytics logEventWithName:firebaseEvent parameters:params];
}

-(void) handleECommerceEventProperties:(NSMutableDictionary *) params properties: (NSDictionary *) properties firebaseEvent:(NSString *) firebaseEvent {
    if (![RudderGA4Utils isEmpty:properties[@"revenue"]] && [RudderGA4Utils isNumber:properties[@"revenue"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"revenue"] doubleValue]] forKey:kFIRParameterValue];
    } else if (![RudderGA4Utils isEmpty:properties[@"value"]] && [RudderGA4Utils isNumber:properties[@"value"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"value"] doubleValue]] forKey:kFIRParameterValue];
    } else if (![RudderGA4Utils isEmpty:properties[@"total"]] && [RudderGA4Utils isNumber:properties[@"total"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"total"] doubleValue]] forKey:kFIRParameterValue];
    }
    if ([EVENT_WITH_PRODUCTS_ARRAY_GA4 containsObject:firebaseEvent] && ![RudderGA4Utils isEmpty:properties[@"products"]]) {
        [self handleProducts:params properties:properties isProductsArray:YES];
    }
    if ([EVENT_WITH_PRODUCTS_AT_ROOT_GA4 containsObject:firebaseEvent]) {
        [self handleProducts:params properties:properties isProductsArray:NO];
    }
    if (![RudderGA4Utils isEmpty:properties[@"currency"]]) {
        [params setValue:[NSString stringWithFormat:@"%@", properties[@"currency"]] forKey:kFIRParameterCurrency];
    } else {
        [params setValue:@"USD" forKey:kFIRParameterCurrency];
    }
    for (NSString *propertyKey in properties) {
        if (ECOMMERCE_PROPERTY_MAPPING_GA4[propertyKey] && ![RudderGA4Utils isEmpty:properties[propertyKey]]) {
            [params setValue:[NSString stringWithFormat:@"%@", properties[propertyKey]] forKey:ECOMMERCE_PROPERTY_MAPPING_GA4[propertyKey]];
        }
    }
    if (![RudderGA4Utils isEmpty:properties[@"shipping"]] && [RudderGA4Utils isNumber:properties[@"shipping"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"shipping"] doubleValue]] forKey:kFIRParameterShipping];
    }
    if (![RudderGA4Utils isEmpty:properties[@"tax"]] && [RudderGA4Utils isNumber:properties[@"tax"]]) {
        [params setValue:[NSNumber numberWithDouble:[properties[@"tax"] doubleValue]] forKey:kFIRParameterTax];
    }
    // order_id is being mapped to FirebaseAnalytics.Param.TRANSACTION_ID.
    if (![RudderGA4Utils isEmpty:properties[@"order_id"]]) {
        [params setValue:[NSString stringWithFormat:@"%@", properties[@"order_id"]] forKey:kFIRParameterTransactionID];
    }
}

-(void) handleProducts:(NSMutableDictionary *) params properties: (NSDictionary *) properties isProductsArray:(BOOL) isProductsArray{
    NSMutableArray *mappedProduct;
    // If Products array is present
    if (isProductsArray){
        NSDictionary *products = [properties objectForKey:@"products"];
        if ([products isKindOfClass:[NSArray class]]) {
            mappedProduct = [[NSMutableArray alloc] init];
            for (NSDictionary *product  in products) {
                NSMutableDictionary *productBundle = [[NSMutableDictionary alloc] init];
                [self putProductValue:productBundle properties:product];
                if ([productBundle count]) {
                    [mappedProduct addObject:productBundle];
                }
            }
        }
    }
    // If product is present at the root level
    else {
        NSMutableDictionary *productBundle = [[NSMutableDictionary alloc] init];
        [self putProductValue:productBundle properties:properties];
        mappedProduct = [[NSMutableArray alloc] init];
        [mappedProduct addObject:productBundle];
    }
    if (![RudderGA4Utils isEmpty:mappedProduct]) {
        [params setValue:mappedProduct forKey:kFIRParameterItems];
    }
}

-(void) putProductValue:(NSMutableDictionary *) params properties:(NSDictionary *) properties {
    for (NSString *key in PRODUCT_PROPERTIES_MAPPING_GA4) {
        if (![RudderGA4Utils isEmpty:properties[key]]) {
            NSString *firebaseKey = PRODUCT_PROPERTIES_MAPPING_GA4[key];
            if ([firebaseKey isEqualToString:kFIRParameterItemID] || [firebaseKey isEqualToString:kFIRParameterItemName] || [firebaseKey isEqualToString:kFIRParameterItemCategory]) {
                [params setValue:[NSString stringWithFormat:@"%@", properties[key]] forKey:firebaseKey];
                continue;;
            }
            if ([RudderGA4Utils isNumber:properties[key]]) {
                if ([firebaseKey isEqualToString:kFIRParameterQuantity]) {
                    [params setValue:[NSNumber numberWithInteger:[(NSNumber *)properties[key] intValue]] forKey:firebaseKey];
                    continue;;
                }
                if ([firebaseKey isEqualToString:kFIRParameterPrice]) {
                    [params setValue:[NSNumber numberWithDouble:[(NSNumber *)properties[key] doubleValue]] forKey:firebaseKey];
                }
            }
        }
    }
}

- (void) attachAllCustomProperties: (NSMutableDictionary *) params properties: (NSDictionary *) properties {
    if([RudderGA4Utils isEmpty:properties] || params == nil) {
        return;
    }
    for (NSString *key in [properties keyEnumerator]) {
        NSString* firebaseKey = [RudderGA4Utils getTrimKey:key];
        id value = properties[key];
        if ([TRACK_RESERVED_KEYWORDS_GA4 containsObject:firebaseKey] || [RudderGA4Utils isEmpty:value]) {
            continue;
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            [params setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:firebaseKey];
        }
        else if([value isKindOfClass:[NSString class]]) {
            if ([value length] > 100) {
                value = [value substringToIndex:[@100 unsignedIntegerValue]];
            }
            [params setValue:value forKey:firebaseKey];
        } else {
            NSString *convertedString = [NSString stringWithFormat:@"%@", value];
            // if length exceeds 100, don't send the property
            if ([convertedString length] <= 100) {
                [params setValue:convertedString forKey:firebaseKey];
            }
        }
    }
}

- (void)reset {
    [FIRAnalytics setUserID:nil];
    [RSLogger logDebug:@"Reset: FIRAnalytics setUserID:nil"];
}

- (void)flush {
    // Firebase doesn't support flush functionality
}


@end

