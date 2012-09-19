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

+(void)fetchCurrentUser:(void (^)(void))completionBlock withLoginBlock:(void (^)(void))loginBlock;
+(void)fetchQuestions:(void(^)(void))completionBlock withLoginBlock:(void(^)(void))loginBlock;
+(void)fetchAnswersForQuestion:(Question *)question withBlock:(void(^)(void))completionBlock;
+(void)saveQuestion:(Question *)question withBlock:(void(^)(int))completitionBlock;
+(void)saveAnswer:(Answer *)answer;
@end
