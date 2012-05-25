//
//  Document.m
//  Wildflowers of Detroit Iphone
//
//  Created by Deep Winter on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RHDocument.h"
#import "RHDataModel.h"

@implementation RHDocument

- (id)init
{
	return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	if (self != nil)
	{
		dictionary = [[NSMutableDictionary alloc] initWithCapacity:capacity];
	}
	return self;
}

- (NSString *) objectForKey: (NSString *) key withDefaultString: (NSString *) defaultValue {
    NSString * value = [dictionary objectForKey:key];
    if(value == nil){
        value = defaultValue;
    }
    return value;
}

- (NSString *) getComment {
    return [self objectForKey:@"comment" withDefaultString:@"No comment"];
}

- (NSString *) getReporter {
    return [self objectForKey:@"reporter" withDefaultString:@""];

}

- (NSString *) getLocationString {
    NSString * latitude = [self objectForKey:@"latitude"];
    NSString * longitude = [self objectForKey:@"longitude"];
    NSString * location = [NSString stringWithFormat:@"%@, %@", latitude, longitude];
    return location;
}

- (NSString *) getDateString{
    return [self objectForKey:@"created_at" withDefaultString:@""];
}

- (float) getLatitude{
    return [[self objectForKey:@"latitude"] floatValue];
}

- (float) getLongitude{
    return [[self objectForKey:@"longitude"] floatValue];
}

- (NSUInteger)count {
    return [dictionary count];
}
- (NSEnumerator *)keyEnumerator{
    return [dictionary keyEnumerator];
}

- (id)objectForKey:(id)aKey {
    return [dictionary objectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    return [dictionary setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey{
    return [dictionary removeObjectForKey:aKey];
}

- (UIImage *)getThumbnail {
    return [RHDataModel getDocumentThumbnail:[self objectForKey:@"_id"]];
}

- (UIImage *)getImage {
    return [RHDataModel getDocumentImage:[self objectForKey:@"_id"]];
}

@end
