//
//  User.h
//  LocationProfiler
//
//  Created by Kris Fields on 9/18/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic) int32_t user_id;
@property (nonatomic, retain) NSSet *userAnswers;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addUserAnswersObject:(NSManagedObject *)value;
- (void)removeUserAnswersObject:(NSManagedObject *)value;
- (void)addUserAnswers:(NSSet *)values;
- (void)removeUserAnswers:(NSSet *)values;

@end
