//
//  ToDoItem.h
//  ios0420b
//
//  Created by Timothy Lee on 4/20/15.
//  Copyright (c) 2015 Eatgo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property NSString *itemName;
@property BOOL completed;
@property (readonly) NSDate *creationDate;

- (id)init:(NSDate *)d;

@end
