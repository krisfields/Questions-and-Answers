//
//  Answer.h
//  LocationProfiler
//
//  Created by Kris Fields on 9/18/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question, UserAnswer;

@interface Answer : NSManagedObject

@property (nonatomic) int32_t answer_id;
@property (nonatomic) int32_t question_id;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Question *question;
@property (nonatomic, retain) NSSet *userAnswers;
@end

@interface Answer (CoreDataGeneratedAccessors)

- (void)addUserAnswersObject:(UserAnswer *)value;
- (void)removeUserAnswersObject:(UserAnswer *)value;
- (void)addUserAnswers:(NSSet *)values;
- (void)removeUserAnswers:(NSSet *)values;

@end
