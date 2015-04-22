//
//  ToDoItem.m
//  ios0420b
//
//  Created by Timothy Lee on 4/20/15.
//  Copyright (c) 2015 Eatgo. All rights reserved.
//

#import "ToDoItem.h"

@interface ToDoItem ()

@property (readwrite) NSDate *creationDate;

@end

@implementation ToDoItem

@synthesize creationDate;

- (id)init {
    return [self init:[NSDate date]];
}

- (id)init:(NSDate *)d {
    self = [super init];
    if (self) {
        self.creationDate = d;
    }
    return self;
}

@end
