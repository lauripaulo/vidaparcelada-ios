//
//  Conta.h
//  VidaParcelada
//
//  Created by Lauri Laux on 13/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Compra, TipoConta;

@interface Conta : NSManagedObject

@property (nonatomic, retain) NSString * descricao;
@property (nonatomic, retain) NSNumber * diaDeVencimento;
@property (nonatomic, retain) NSString * empresa;
@property (nonatomic, retain) NSDecimalNumber * jurosMes;
@property (nonatomic, retain) NSDecimalNumber * limite;
@property (nonatomic, retain) NSDecimalNumber * limiteUsuario;
@property (nonatomic, retain) NSNumber * melhorDiaDeCompra;
@property (nonatomic, retain) NSSet *compras;
@property (nonatomic, retain) TipoConta *tipo;
@end

@interface Conta (CoreDataGeneratedAccessors)

- (void)addComprasObject:(Compra *)value;
- (void)removeComprasObject:(Compra *)value;
- (void)addCompras:(NSSet *)values;
- (void)removeCompras:(NSSet *)values;

@end
