//
//  Compra.h
//  VidaParcelada
//
//  Created by Lauri Laux on 08/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Conta, Parcela;

@interface Compra : NSManagedObject

@property (nonatomic, retain) NSDate * dataDaCompra;
@property (nonatomic, retain) NSString * estado;
@property (nonatomic, retain) NSNumber * qtdeTotalDeParcelas;
@property (nonatomic, retain) NSDecimalNumber * valorTotal;
@property (nonatomic, retain) NSString * descricao;
@property (nonatomic, retain) NSString * detalhes;
@property (nonatomic, retain) Conta *origem;
@property (nonatomic, retain) NSSet *parcelas;
@end

@interface Compra (CoreDataGeneratedAccessors)

- (void)addParcelasObject:(Parcela *)value;
- (void)removeParcelasObject:(Parcela *)value;
- (void)addParcelas:(NSSet *)values;
- (void)removeParcelas:(NSSet *)values;

@end
