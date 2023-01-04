//
//  RudderUtils.h
//  Rudder-Firebase
//
//  Created by Abhishek Pandey on 28/10/21.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>

#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseAnalytics/FirebaseAnalytics.h>



NS_ASSUME_NONNULL_BEGIN

@interface RudderGA4Utils : NSObject


extern NSArray const* IDENTIFY_RESERVED_KEYWORDS_GA4;
extern NSArray const* TRACK_RESERVED_KEYWORDS_GA4;
extern NSDictionary const* ECOMMERCE_EVENTS_MAPPING_GA4;
extern NSDictionary const* PRODUCT_PROPERTIES_MAPPING_GA4;
extern NSArray const* EVENT_WITH_PRODUCTS_ARRAY_GA4;
extern NSDictionary const* ECOMMERCE_PROPERTY_MAPPING_GA4;
extern NSArray const* EVENT_WITH_PRODUCTS_AT_ROOT_GA4;

- (id)init;
+(BOOL) isEmpty:(NSObject *) value;
+(NSString *) getTrimKey:(NSString *) key;
+(BOOL) isNumber:(NSObject *)value;

@end

NS_ASSUME_NONNULL_END
