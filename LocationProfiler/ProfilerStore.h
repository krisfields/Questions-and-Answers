//
//  ProfilerStore.h
//  LocationProfiler
//
//  Created by Kris Fields on 9/17/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Question;
@class Answer;

@interface ProfilerStore : NSObject
+(void)setupProfilerStore:(NSString *)userName password:(NSString *)password;

+(void)fetchQuestions:(void(^)(void))completionBlock;
+(void)fetchAnswersForQuestion:(Question *)question withBlock:(void(^)(void))completionBlock;
@end
