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
#import "User.h"
#import "UserAnswer.h"

static RKObjectManager *profilerObjectManager;
static User *currentUser;

@implementation ProfilerStore
+(User *)currentUser {
    return currentUser;
}
+(void)setupProfilerStore {
    RKClient *profilerClient = [RKClient clientWithBaseURLString:@"http://localhost:3000"];

    
    profilerObjectManager = [RKObjectManager new];
    profilerObjectManager.client = profilerClient;
    
    profilerObjectManager.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"profilerStore.sqlite3"];

    [self setUpQuestionMapping];
    [self setUpAnswerMapping];
    [self setUpUserMapping];
    [self setUpUserAnswerMapping];
}
+(void)setProfilerStoreUserName:(NSString *)userName password:(NSString *)password {
    profilerObjectManager.client.username = userName;
    profilerObjectManager.client.password = password;
}
+(void)setUpUserMapping {
    RKManagedObjectMapping *userMapping = [RKManagedObjectMapping mappingForClass:[User class] inManagedObjectStore:profilerObjectManager.objectStore];
    
    userMapping.objectClass = [User class];
    [userMapping mapKeyPath:@"id" toAttribute:@"user_id"];
    userMapping.primaryKeyAttribute = @"user_id";
    
    [profilerObjectManager.mappingProvider addObjectMapping:userMapping];
    
    RKObjectMapping *serializationMapping = userMapping.inverseMapping;
    serializationMapping.rootKeyPath = @"user";
    [profilerObjectManager.mappingProvider setSerializationMapping:serializationMapping forClass:[User class]];
    
    [profilerObjectManager.router routeClass:[User class] toResourcePath:@"/users.json"];
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
+(void)setUpUserAnswerMapping {
    RKManagedObjectMapping *userAnswerMapping = [RKManagedObjectMapping mappingForClass:[UserAnswer class] inManagedObjectStore:profilerObjectManager.objectStore];
    
    userAnswerMapping.objectClass = [UserAnswer class];
    [userAnswerMapping mapKeyPath:@"id" toAttribute:@"user_answer_id"];
    [userAnswerMapping mapAttributes:@"user_id", @"answer_id", nil];
    userAnswerMapping.primaryKeyAttribute = @"user_answer_id";
    RKObjectMapping *serializationMapping = userAnswerMapping.inverseMapping;
    serializationMapping.rootKeyPath = @"user_answer"; //user_answer or userAnswer?
    
    [userAnswerMapping mapRelationship:@"user" withMapping:[profilerObjectManager.mappingProvider objectMappingForClass:[User class]]];
    
    [userAnswerMapping connectRelationship:@"user" withObjectForPrimaryKeyAttribute:@"user_id"];
    [userAnswerMapping mapRelationship:@"answer" withMapping:[profilerObjectManager.mappingProvider objectMappingForClass:[Answer class]]];
    
    [userAnswerMapping connectRelationship:@"answer" withObjectForPrimaryKeyAttribute:@"answer_id"];
    [profilerObjectManager.mappingProvider addObjectMapping:userAnswerMapping];
    
    [profilerObjectManager.mappingProvider setSerializationMapping:serializationMapping forClass:[UserAnswer class]];
    
    [profilerObjectManager.router routeClass:[UserAnswer class] toResourcePath:@"/user_answers.json"];
}
+(void)fetchCurrentUser:(void (^)(void))completionBlock withLoginBlock:(void (^)(void))loginBlock {
    [profilerObjectManager loadObjectsAtResourcePath:@"/users.json?current_user=true" usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[User class]];
        loader.onDidLoadObject = ^(User *userObject) {
            currentUser = userObject;
            if (completionBlock)
                completionBlock();
        };
        loader.onDidFailLoadWithError = ^(NSError* err) {
            NSLog(@"%@", err);
            if (loginBlock)
                loginBlock();
        };
    }];
}
+(void)fetchQuestions:(void (^)(void))completionBlock {
    [profilerObjectManager loadObjectsAtResourcePath:@"/questions.json" usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[Question class]];
        
        loader.onDidLoadObjects = ^(NSArray* objects) {
            if (completionBlock)
                completionBlock();
            NSLog(@"INSIDE FETCH QUESTIONS ONDIDLOADOBJECTS");
        };
        loader.onDidFailLoadWithError = ^(NSError* err) {
            NSLog(@"%@", err);
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
+(void)saveUserAnswer:(UserAnswer *)userAnswer {
    [profilerObjectManager postObject:userAnswer usingBlock:^(RKObjectLoader *loader) {
        loader.objectMapping = [profilerObjectManager.mappingProvider objectMappingForClass:[UserAnswer class]];
        loader.onDidLoadResponse = ^(RKResponse *response){
            NSLog(@"RESPONSE to USERANSWER SAVE:  %@",response.bodyAsString);
        };
    }];
}
@end
