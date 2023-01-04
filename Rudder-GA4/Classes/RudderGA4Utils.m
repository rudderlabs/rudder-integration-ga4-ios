//
//  RudderUtils.h
//  Rudder-Firebase
//
//  Created by Abhishek Pandey on 28/10/21.
//

#import "RudderGA4Utils.h"

@implementation RudderGA4Utils

NSArray * IDENTIFY_RESERVED_KEYWORDS_GA4;
NSArray *TRACK_RESERVED_KEYWORDS_GA4;
NSDictionary *ECOMMERCE_EVENTS_MAPPING_GA4;
NSDictionary *PRODUCT_PROPERTIES_MAPPING_GA4;
NSArray *EVENT_WITH_PRODUCTS_ARRAY_GA4;
NSDictionary *ECOMMERCE_PROPERTY_MAPPING_GA4;
NSArray *EVENT_WITH_PRODUCTS_AT_ROOT_GA4;

+ (void)initialize {
    IDENTIFY_RESERVED_KEYWORDS_GA4 =  [[NSArray alloc] initWithObjects:@"age", @"gender", @"interest", nil];
    
    TRACK_RESERVED_KEYWORDS_GA4 = [[NSArray alloc] initWithObjects:@"product_id", @"name", @"category", @"quantity", @"price", @"currency", @"value", @"revenue", @"total", @"tax", @"shipping", @"coupon", @"cart_id", @"payment_method", @"query", @"list_id", @"promotion_id", @"creative", @"affiliation", @"share_via", @"products", @"order_id", kFIRParameterScreenName, nil];
    
    ECOMMERCE_EVENTS_MAPPING_GA4 = @{
        ECommPaymentInfoEntered : kFIREventAddPaymentInfo,
        ECommProductAdded : kFIREventAddToCart,
        ECommProductAddedToWishList : kFIREventAddToWishlist,
        ECommCheckoutStarted : kFIREventBeginCheckout,
        ECommOrderCompleted : kFIREventPurchase,
        ECommOrderRefunded : kFIREventRefund,
        ECommProductsSearched : kFIREventSearch,
        ECommCartShared : kFIREventShare,
        ECommProductShared : kFIREventShare,
        ECommProductViewed : kFIREventViewItem,
        ECommProductListViewed : kFIREventViewItemList,
        ECommProductRemoved : kFIREventRemoveFromCart,
        ECommProductClicked : kFIREventSelectContent,
        ECommPromotionViewed : kFIREventViewPromotion,
        ECommPromotionClicked : kFIREventSelectPromotion,
        ECommCartViewed : kFIREventViewCart
    };

    PRODUCT_PROPERTIES_MAPPING_GA4 = @{
        @"product_id" : kFIRParameterItemID,
        @"name" : kFIRParameterItemName,
        @"category" : kFIRParameterItemCategory,
        @"quantity" : kFIRParameterQuantity,
        @"price" : kFIRParameterPrice
    };

    EVENT_WITH_PRODUCTS_ARRAY_GA4 = [[NSArray alloc] initWithObjects:
                                 kFIREventBeginCheckout,
                                 kFIREventPurchase,
                                 kFIREventRefund,
                                 kFIREventViewItemList,
                                 kFIREventViewCart,
                                 nil];
    
    EVENT_WITH_PRODUCTS_AT_ROOT_GA4 = [[NSArray alloc] initWithObjects:
                                   kFIREventAddToCart,
                                   kFIREventAddToWishlist,
                                   kFIREventViewItem,
                                   kFIREventRemoveFromCart,
                                   nil];
    
    ECOMMERCE_PROPERTY_MAPPING_GA4 = @{
        @"payment_method" : kFIRParameterPaymentType,
        @"coupon" : kFIRParameterCoupon,
        @"query" : kFIRParameterSearchTerm,
        @"list_id" : kFIRParameterItemListID,
        @"promotion_id" : kFIRParameterPromotionID,
        @"creative" : kFIRParameterCreativeName,
        @"affiliation" : kFIRParameterAffiliation,
        @"share_via" : kFIRParameterMethod
    };
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

+(NSString *) getTrimKey:(NSString *) key {
    NSString * event = [[[key lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSUInteger trimLength = [@40 unsignedIntegerValue];
    if([event length] > trimLength) {
        event = [event substringToIndex:trimLength];
    }
    return event;
}

+(BOOL) isEmpty:(NSObject *) value {
    if (value == nil) {
        return true;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [(NSString *)value isEqualToString:@""];
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)value count] == 0;
    }
    if ([value isKindOfClass:[NSMutableArray class]]) {
        return [(NSMutableArray *)value count] == 0;
    }
    return false;
}

+(BOOL) isNumber:(NSObject *)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        return true;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *number = [formatter numberFromString:[NSString stringWithFormat:@"%@", value]];
        return !!number; // If the string is not numeric, number will be nil
    }
    return false;
}

@end
