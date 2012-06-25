//
//  Conta+AddOn.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 16/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Conta.h"

@interface Conta (AddOn)

// cria uma nova conta com os dados passados como parametro
// os atributos 'compras' e 'tipo' são inicializados automaticamente
// na implementação do método.
+ (Conta *)contaComDescricao:(NSString *)descricao 
                daEmpresa:(NSString *) empresa
       comVencimentoNoDia:(NSNumber *) diaDeVencimento
                eJurosMes:(NSDecimalNumber *) jurosMes
           comLimiteTotal:(NSDecimalNumber *) limite
     comMelhorDiaDeCompra:(NSNumber *) melhorDiaDeCompra
                inContext:(NSManagedObjectContext *)context;

// Retorna todas as contas atualmente cadastradas para usar em
// um UIPickerView, por exemplo.
+ (NSArray *)contasCadastradasUsandoContext:(NSManagedObjectContext *)context;

@end

// Delegate para avisar a TableView cliente que os dados da conta foram atualizados
@protocol AlteracaoDeContaDelegate <NSObject>

- (void)contaFoiAlterada:(Conta *)conta;

@end