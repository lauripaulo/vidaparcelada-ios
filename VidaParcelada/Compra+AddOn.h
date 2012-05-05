//
//  Compra+AddOn.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 23/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Compra.h"

//
// Estados possíveis da compra
//
extern NSString * const COMPRA_PENDENTE_PAGAMENTO; // Sem nenhuma parcela paga
extern NSString * const COMPRA_PAGAMENTO_PARCIAL; // Com pelo menos uma parcela paga
extern NSString * const COMPRA_PAGAMENTO_EFETUADO; // Todas as parcela pagas

@interface Compra (AddOn)

//
// Cria uma nova compra
//
+(Compra *)compraComDescricao:(NSString *)descricao
                 dataDaCompra:(NSDate *)data
                    comEstado:(NSString *)estado
               qtdeDeParcelas:(NSNumber *)parcelas
                   valorTotal:(NSDecimalNumber *)valorTotal
                     comConta:(Conta *)conta
                    inContext:(NSManagedObjectContext *)context;

//
// Cria as parcelas da compra passada como parametro com a opção de apagar
// ou não as parcelas já existentes
//
+(NSSet *)criarParcelasDaCompra:(Compra *)compra
                      inContext:(NSManagedObjectContext *)context;

// Escolhe a primeira conta disponivel para uso
+(Conta *)retornaContaDefaultNoContexto:(NSManagedObjectContext *)context;

//
// Apaga todas as parcelas da compra passada como parametro
//
+(void)apagarParcelasDaCompra:(Compra *)compra;

@end

//
// Define um delegate para avisar a quem quiser sobre mudanças
// no estado do objeto.
//
// Delegate para avisar a TableView cliente que os dados da conta foram atualizados
@protocol AlteracaoDeCompraDelegate <NSObject>

- (void)compraFoiAlterada:(Compra *)compra;

@end


