//
//  Compra+AddOn.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 23/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
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
                  comDetalhes:(NSString *)detalhes
                 dataDaCompra:(NSDate *)data
                    comEstado:(NSString *)estado
               qtdeDeParcelas:(NSNumber *)parcelas
                   valorTotal:(NSDecimalNumber *)valorTotal
                     comConta:(Conta *)conta
   assumirAnterioresComoPagas:(BOOL)parcelasAntigasPagas
                    inContext:(NSManagedObjectContext *)context;

//
// Cria as parcelas da compra passada como parametro com a opção de apagar
// ou não as parcelas já existentes
//
+(NSSet *)criarParcelasDaCompra:(Compra *)compra
     assumirAnterioresComoPagas:(BOOL)parcelasAntigasPagas
                      inContext:(NSManagedObjectContext *)context;

// Escolhe a primeira conta disponivel para uso
+(Conta *)retornaContaDefaultNoContexto:(NSManagedObjectContext *)context;

//
// Apaga todas as parcelas da compra passada como parametro
//
+(void)apagarParcelasDaCompra:(Compra *)compra 
                    inContext:(NSManagedObjectContext *)context;

// Calcula o melhor dia de compra do mes passado como parametro.
+ (NSDate *)melhorDiaDeCompraDoMes:(Conta *)conta dataAtual:(NSDate *)data;

// Calcula o vencimento da parcela a partir do melhor dia de comopra
// e a data da compra e o numero de meses a partir de hoje.
// Para calcula a uma data de vencimento que já passou basta passar
// uma quantidade negativa de meses no parametro i.
+ (NSDate *)calculaVencimentoDaParcela:(Conta *)conta 
                          dataDaCompra:(NSDate *)data 
                                 numDaParcela:(int)i;

// Retorna a quantidade de compras cadastradas nesse momento
// na base de dados, para uma conta informada. Passsar nil para a conta 
// caso deseje listar todas as compras independente de conta.
+(int) quantidadeDeCompras:(NSManagedObjectContext *)context comConta:(Conta *)conta;


@end

//
// Define um delegate para avisar a quem quiser sobre mudanças
// no estado do objeto.
//
// Delegate para avisar a TableView cliente que os dados da conta foram atualizados
@protocol AlteracaoDeCompraDelegate <NSObject>

- (void)compraFoiAlterada:(Compra *)compra;

@end


