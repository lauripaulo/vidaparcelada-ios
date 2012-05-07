//
//  Parcela+AddOn.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 23/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Parcela.h"

//
// Estados possíveis da compra
//
extern NSString * const PARCELA_PENDENTE_PAGAMENTO; // Sem nenhuma parcela paga
extern NSString * const PARCELA_PAGA; // Com pelo menos uma parcela paga
extern NSString * const PARCELA_VENCIDA; // Todas as parcela pagas

@interface Parcela (AddOn)

//
// Cria uma nova parcela
//
+ (Parcela *)novaParcelaComDescricao:(NSString *)descricao
                   eDataDeVencimento:(NSDate *)dataDeVencimento
                           comEstado:(NSString *)estado
                    eNumeroDaParcela:(NSNumber *)numeroDaParcela
                            comValor:(NSDecimalNumber *)valor
                     pertenceACompra:(Compra *)compra
                           inContext:(NSManagedObjectContext *)context;

@end

//
// Define um delegate para avisar a quem quiser sobre mudanças
// no estado do objeto.
//
// Delegate para avisar a TableView cliente que os dados da conta foram atualizados
@protocol AlteracaoDeParcelaDelegate <NSObject>

- (void)parcelaFoiAlterada:(Parcela *)parcela;

@end
