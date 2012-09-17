//
//  Answer.h
//  
//
//  Created by Kris Fields on 9/16/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic) int32_t question_id;
@property (nonatomic) int32_t id;
@property (nonatomic, retain) Question *question;


@end
