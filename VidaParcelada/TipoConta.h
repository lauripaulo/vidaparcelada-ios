//
//  TipoConta.h
//  VidaParcelada
//
//  Created by Lauri P. Laux Jr on 26/07/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conta;

@interface TipoConta : NSManagedObject

@property (nonatomic, retain) NSString * descricao;
@property (nonatomic, retain) NSString * nome;
@property (nonatomic, retain) NSNumber * tipo;
@property (nonatomic, retain) NSSet *conta;
@end

@interface TipoConta (CoreDataGeneratedAccessors)

- (void)addContaObject:(Conta *)value;
- (void)removeContaObject:(Conta *)value;
- (void)addConta:(NSSet *)values;
- (void)removeConta:(NSSet *)values;

@end
