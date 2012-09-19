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
    [questionMapping mapKeyPath:@"id" toAttribute:@"question_id"];
    [questionMapping mapAttributes:@"text", nil];
    questionMapping.primaryKeyAttribute = @"question_id";
    
    [profilerObjectManager.mappingProvider addObjectMapping:questionMapping];
    
    RKObjectMapping *serializationMapping = questionMapping.inverseMapping;
    serializationMapping.rootKeyPath = @"question";
    [profilerObjectManager.mappingProvider setSerializationMapping:serializationMapping forClass:[Question class]];
    
    [profilerObjectManager.router routeClass:[Question class] toResourcePath:@"/questions.json"];
}
+(void)setUpAnswerMapping {
    RKManagedObjectMapping *answerMapping = [RKManagedObjectMapping mappingForClass:[Answer class] inManagedObjectStore:profilerObjectManager.objectStore];
    
    answerMapping.objectClass = [Answer class];
    [answerMapping mapKeyPath:@"id" toAttribute:@"answer_id"];
    [answerMapping mapAttributes:@"question_id", @"text", nil];
    answerMapping.primaryKeyAttribute = @"answer_id";
    RKObjectMapping *serializationMapping = answerMapping.inverseMapping;
    serializationMapping.rootKeyPath = @"answer";
    [answerMapping mapRelationship:@"question" withMapping:[profilerObjectManager.mappingProvider objectMappingForClass:[Question class]]];
    
    [answerMapping connectRelationship:@"question" withObjectForPrimaryKeyAttribute:@"question_id"];
    
    [profilerObjectManager.mappingProvider addObjectMapping:answerMapping];
    

    [profilerObjectManager.mappingProvider setSerializationMapping:serializationMapping forClass:[Answer class]];
    
    [profilerObjectManager.router routeClass:[Answer class] toResourcePath:@"/answers.json"];
}
+(void)fetchCurrentUser:(void (^)(void))completionBlock withLoginBlock:(void (^)(void))loginBlock {
//    [profilerObjectManager loadObjectsAtResourcePath:@"/users.json" usingBlock:^(RKObjectLoader *loader) {
//        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[User class]];
//        loader.onDidLoadObjects = ^(NSArray* objects) {
//            if (completionBlock)
//                completionBlock();
//            NSLog(@"INSIDE FETCH QUESTIONS ONDIDLOADOBJECTS");
//        };
//        loader.onDidFailLoadWithError = ^(NSError* err) {
//            NSLog(@"%@", err);
//            if (loginBlock)
//                loginBlock();
//        };
//    }];
}
+(void)fetchQuestions:(void (^)(void))completionBlock withLoginBlock:(void (^)(void))loginBlock {
    [profilerObjectManager loadObjectsAtResourcePath:@"/questions.json" usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[Question class]];
        
        loader.onDidLoadObjects = ^(NSArray* objects) {
            if (completionBlock)
                completionBlock();
            NSLog(@"INSIDE FETCH QUESTIONS ONDIDLOADOBJECTS");
        };
        loader.onDidFailLoadWithError = ^(NSError* err) {
            NSLog(@"%@", err);
            if (loginBlock)
                loginBlock();
        };
    }];
}
+(void)fetchAnswersForQuestion:(Question *)question withBlock:(void (^)(void))completionBlock {
    NSString *question_id_as_string = [NSString stringWithFormat:@"%d.json", question.question_id];
    NSString *urlString = [@"/questions/:question_id?show=true" interpolateWithObject:@{
        @"question_id" : question_id_as_string
     }];
    [profilerObjectManager loadObjectsAtResourcePath:urlString usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[Answer class]];
        
        loader.onDidLoadObjects = ^(NSArray* objects) {
            if (completionBlock)
                completionBlock();
        };
        loader.onDidLoadResponse = ^(RKResponse *response){
            NSLog(@"RESPONSE:  %@",response.bodyAsString);
        };
        loader.onDidFailLoadWithError = ^(NSError* err) {
            NSLog(@"%@", err);
        };
    }];
}
+(void)saveQuestion:(Question *)question withBlock:(void(^)(int))completitionBlock {
    [profilerObjectManager postObject:question usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[Question class]];
        loader.onDidLoadObject = ^(NSObject *object){
            completitionBlock(question.question_id);
        };
    }];
}
+(void)saveAnswer:(Answer *)answer {
    [profilerObjectManager postObject:answer usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[Answer class]];
        loader.onDidLoadResponse = ^(RKResponse *response){
            NSLog(@"RESPONSE:  %@",response.bodyAsString);
        };
    }];
}
@end
