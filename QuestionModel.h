//
//  QuestionModel.h
//  
//
//  Created by Kris Fields on 9/16/12.
//
//

#import <Foundation/Foundation.h>

@interface QuestionModel : NSObject

@property (nonatomic, strong) NSArray *answers;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) int question_id;

@end
