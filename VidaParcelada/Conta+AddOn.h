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
       cartaoPreferencial:(BOOL)preferencial
                inContext:(NSManagedObjectContext *)context;

// Retorna todas as contas atualmente cadastradas para usar em
// um UIPickerView, por exemplo.
+ (NSArray *)contasCadastradasUsandoContext:(NSManagedObjectContext *)context;

// Retorna a quantidade de compras cadastradas nesse momento
// na base de dados
+(int) quantidadeDeContas:(NSManagedObjectContext *)context;

+(void)removeContaTotalmente:(Conta *)conta
                   inContext:(NSManagedObjectContext *)context;


@end

// Delegate para avisar a TableView cliente que os dados da conta foram atualizados
@protocol AlteracaoDeContaDelegate <NSObject>

- (void)contaFoiAlterada:(Conta *)conta;

@end

// Utilizado para avisar que um tipo de conta foi escolhida na tela
// de seleção de tipos.
@protocol ContaEscolhidaDelegate <NSObject>

- (void)contaEscolhida:(Conta *)conta;

@end
