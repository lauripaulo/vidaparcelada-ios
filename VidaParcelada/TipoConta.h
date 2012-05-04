//
//  TipoConta.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 17/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conta;

@interface TipoConta : NSManagedObject

@property (nonatomic, retain) NSString * descricao;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSSet *conta;
@end

@interface TipoConta (CoreDataGeneratedAccessors)

- (void)addContaObject:(Conta *)value;
- (void)removeContaObject:(Conta *)value;
- (void)addConta:(NSSet *)values;
- (void)removeConta:(NSSet *)values;

@end