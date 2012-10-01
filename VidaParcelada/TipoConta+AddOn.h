//
//  TipoConta+AddOn.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 15/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import "TipoConta.h"

@interface TipoConta (AddOn)

+(TipoConta *)contaComNome:(NSString *)nome 
                eDescricao:(NSString *)descricao 
       identificadorDeTipo:(int)tipo
                 inContext:(NSManagedObjectContext *)context;

@end

// Utilizado para avisar que um tipo de conta foi escolhida na tela
// de seleção de tipos.
@protocol TipoContaEscolhidoDelegate <NSObject>

- (void)tipoContaEscolhido:(TipoConta *)tipoConta;

@end

