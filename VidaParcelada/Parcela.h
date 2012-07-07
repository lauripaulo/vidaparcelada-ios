//
//  Parcela.h
//  VidaParcelada
//
//  Created by Lauri Laux on 06/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Compra;

@interface Parcela : NSManagedObject

@property (nonatomic, retain) NSDate * dataVencimento;
@property (nonatomic, retain) NSString * descricao;
@property (nonatomic, retain) NSString * estado;
@property (nonatomic, retain) NSNumber * numeroDaParcela;
@property (nonatomic, retain) NSString * tMesAno;
@property (nonatomic, retain) NSDecimalNumber * valor;
@property (nonatomic, retain) Compra *compra;

@end
