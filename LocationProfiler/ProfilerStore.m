//
//  ProfilerStore.m
//  LocationProfiler
//
//  Created by Kris Fields on 9/17/12.
//  Copyright (c) 2012 Kris Fields. All rights reserved.
//

#import "ProfilerStore.h"
#import <RestKit/RestKit.h>
#import "Question.h"
#import "Answer.h"

static RKObjectManager *profilerObjectManager;

@implementation ProfilerStore
+(void)setupProfilerStore:(NSString *)userName password:(NSString *)password {
    RKClient *profilerClient = [RKClient clientWithBaseURLString:@"http://localhost:3000"];
    profilerClient.username = userName;
    profilerClient.password = password;
    
    profilerObjectManager = [RKObjectManager new];
    profilerObjectManager.client = profilerClient;
    
    profilerObjectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"profilerStore.sqlite3"];

    [self setUpQuestionMapping];
    [self setUpAnswerMapping];
}

+(void)setUpQuestionMapping {
    RKManagedObjectMapping *questionMapping = [RKManagedObjectMapping mappingForClass:[Question class] inManagedObjectStore:profilerObjectManager.objectStore];
    
    questionMapping.objectClass = [Question class];
//    [questionMapping mapKeyPath:@"id" toAttribute:@"questionId"];
    [questionMapping mapAttributes:@"id", @"text", nil];
    questionMapping.primaryKeyAttribute = @"id";
    
    [profilerObjectManager.mappingProvider addObjectMapping:questionMapping];
    
    RKObjectMapping *serializationMapping = questionMapping.inverseMapping;
    serializationMapping.rootKeyPath = @"question";
    [profilerObjectManager.mappingProvider setSerializationMapping:serializationMapping forClass:[Question class]];
    
    [profilerObjectManager.router routeClass:[Question class] toResourcePath:@"/questions.json"];
}
+(void)setUpAnswerMapping {
    RKManagedObjectMapping *answerMapping = [RKManagedObjectMapping mappingForClass:[Question class] inManagedObjectStore:profilerObjectManager.objectStore];
    
    answerMapping.objectClass = [Answer class];
    //    [answerMapping mapKeyPath:@"id" toAttribute:@"answerId"];
    [answerMapping mapAttributes:@"id", @"question_id", @"text", nil];
    answerMapping.primaryKeyAttribute = @"id";
    
    [profilerObjectManager.mappingProvider addObjectMapping:answerMapping];
    
    RKObjectMapping *serializationMapping = answerMapping.inverseMapping;
    serializationMapping.rootKeyPath = @"answer";
    [profilerObjectManager.mappingProvider setSerializationMapping:serializationMapping forClass:[Answer class]];
    
    [profilerObjectManager.router routeClass:[Answer class] toResourcePath:@"/answers.json"];
}

+(void)fetchQuestions:(void (^)(void))completionBlock {
    [profilerObjectManager loadObjectsAtResourcePath:@"/questions.json" usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[Question class]];
        
        loader.onDidLoadObjects = ^(NSArray* objects) {
            if (completionBlock)
                completionBlock();
        };
        loader.onDidFailLoadWithError = ^(NSError* err) {
            NSLog(@"%@", err);
        };
    }];
}
+(void)fetchAnswersForQuestion:(Question *)question withBlock:(void (^)(void))completionBlock {
    NSString *question_id_as_string = [NSString stringWithFormat:@"%d", question.id];
    NSString *urlString = [@"/questions/:question_id?show=:true" interpolateWithObject:@{
        @"question_id" : question_id_as_string
     }];
    [profilerObjectManager loadObjectsAtResourcePath:urlString usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[Answer class]];
        
        loader.onDidLoadObjects = ^(NSArray* objects) {
            if (completionBlock)
                completionBlock();
        };
        loader.onDidFailLoadWithError = ^(NSError* err) {
            NSLog(@"%@", err);
        };
    }];
}
+(void)saveQuestion:(Question *)question {
    [profilerObjectManager postObject:question delegate:nil];
}
+(void)saveAnswer:(Answer *)answer {
    [profilerObjectManager postObject:answer delegate:nil];
}
@end
