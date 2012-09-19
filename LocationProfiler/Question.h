//
//  Question.h
//  
//
//  Created by Kris Fields on 9/16/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer;

@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic) int32_t question_id;
@property (nonatomic, retain) NSSet *answers;
@end

@interface Question (CoreDataGeneratedAccessors)

- (void)addAnswersObject:(Answer *)value;
- (void)removeAnswersObject:(Answer *)value;
- (void)addAnswers:(NSSet *)values;
- (void)removeAnswers:(NSSet *)values;

@end
