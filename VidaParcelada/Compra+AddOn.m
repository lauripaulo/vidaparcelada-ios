//
//  Compra+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior Laux on 23/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Compra+AddOn.h"
#import "Parcela+AddOn.h"
#import "Conta+AddOn.h"
#import "VidaParceladaHelper.h"

//
// Estados possíveis da compra
//
NSString * const COMPRA_PENDENTE_PAGAMENTO = @"Pendente";
NSString * const COMPRA_PAGAMENTO_PARCIAL = @"Parcial";
NSString * const COMPRA_PAGAMENTO_EFETUADO = @"Pago";

@implementation Compra (AddOn)

+(Compra *)compraComDescricao:(NSString *)descricao
                 dataDaCompra:(NSDate *)data
                    comEstado:(NSString *)estado
               qtdeDeParcelas:(NSNumber *)parcelas
                   valorTotal:(NSDecimalNumber *)valorTotal
                     comConta:(Conta *)conta
   assumirAnterioresComoPagas:(BOOL)parcelasAntigasPagas
                    inContext:(NSManagedObjectContext *)context
{
    Compra *novaCompra = nil;
    
    NSLog(@"(>) compraComDescricao: %@, %@, %@, %@, %@, %@, %@, %@", descricao, data, estado, parcelas, valorTotal, conta, (parcelasAntigasPagas ? @"YES" : @"NO"), context);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Compra"];
    request.predicate = [NSPredicate predicateWithFormat:@"descricao = %@ AND estado = %@ AND valorTotal = %@", descricao, estado, valorTotal];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];

    if (!matches || ([matches count] > 0)) {
        NSLog(@"(!) compraComDescricao: [matches count] = %d", [matches count]);
        //
        // Apaga todos os itens errados...
        //
        for (Compra *compra in matches) {
            [context deleteObject:compra];
            NSLog(@"(!) compraComDescricao: deleted = %@", compra);
        }
        
        // ...e chama novamente de forma recursiva
        // este metodo de criação.
        novaCompra = [self compraComDescricao:descricao 
                                 dataDaCompra:data 
                                    comEstado:estado 
                               qtdeDeParcelas:parcelas 
                                   valorTotal:valorTotal 
                                     comConta:conta 
                   assumirAnterioresComoPagas:parcelasAntigasPagas 
                                    inContext:context];
        
    } else {
        //
        // Cria o novo objeto
        //
        novaCompra = [NSEntityDescription insertNewObjectForEntityForName:@"Compra" inManagedObjectContext:context];
        novaCompra.descricao = descricao;
        novaCompra.dataDaCompra = data;
        novaCompra.estado = estado;
        novaCompra.valorTotal = valorTotal;
        novaCompra.qtdeTotalDeParcelas = parcelas;
        novaCompra.origem = conta;
        [self criarParcelasDaCompra:novaCompra assumirAnterioresComoPagas:YES inContext:context];
        
    }

    [context save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    NSLog(@"(<) compraComDescricao: return = %@", novaCompra);

    return novaCompra;
}

+(Conta *)retornaContaDefaultNoContexto:(NSManagedObjectContext *)context
{
    Conta *conta = nil;
    
    NSLog(@"(>) retornaContaDefaultNoContexto: %@", context);

    // para a conta vamos selecionar o primeiro objeto da tabela conta
    // Query para encontrar o primeiro TipoConta e associar a conta que estamos criando
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSError *error = nil;
    NSArray *tipos = [context executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];

    if (tipos && [tipos count] > 0) {
       conta = [tipos objectAtIndex:0];
    }
    
    NSLog(@"(<) retornaContaDefaultNoContexto: return = %@", conta);

    return conta;
}

+ (NSDate *)melhorDiaDeCompraDoMes:(Conta *)conta 
                         dataAtual:(NSDate *)data
{
    NSLog(@"(>) melhorDiaDeCompraDoMes: %@, %@", conta, data);

    // para calcular os vencimentos das parcelas
    NSCalendar *calendario = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dataBase = [calendario components:unitFlags fromDate:data];

    // Calculando o melhor dia
    NSDateComponents *melhorDiaComps = [[NSDateComponents alloc] init];
    [melhorDiaComps setDay:[conta.melhorDiaDeCompra intValue]];
    [melhorDiaComps setMonth:(dataBase.month)];
    [melhorDiaComps setYear:dataBase.year];
    
    NSDate *melhorDia = [calendario dateFromComponents:melhorDiaComps];
   
    NSLog(@"(<) melhorDiaDeCompraDoMes: return = %@", melhorDia);
    
    return melhorDia;
   
}

+ (NSDate *)calculaVencimentoDaParcela:(Conta *)conta 
                          dataDaCompra:(NSDate *)data 
                                 numDaParcela:(int)i
{
    NSLog(@"(>) calculaVencimentoDaParcela: %@, %@, %d", conta, data, i);

    // Vamos precisar de um calendário
    // para calcular os vencimentos das parcelas
    NSCalendar *calendario = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dataDaCompraComps = [calendario components:unitFlags fromDate:data];
    // Calculando o vencimento...
    NSDateComponents *dataDeVencimentoComps = [[NSDateComponents alloc] init];
    NSDate *melhorDiaDesteMes = [Compra melhorDiaDeCompraDoMes:conta dataAtual:data];
    
    if ([[data laterDate:melhorDiaDesteMes] isEqualToDate:data] || [data isEqualToDate:melhorDiaDesteMes]) {
        // Se a compra for *durante* OU *depois* do melhor dia do mes
        // o vencimento será no próximo mês
        [dataDeVencimentoComps setDay:[conta.diaDeVencimento intValue]];
        [dataDeVencimentoComps setMonth:(dataDaCompraComps.month +i)];
        [dataDeVencimentoComps setYear:dataDaCompraComps.year];        
    } else {
        // Se for antes do melhor dia a data de vencimento é durante o 
        // mês atual
        [dataDeVencimentoComps setDay:[conta.diaDeVencimento intValue]];
        [dataDeVencimentoComps setMonth:(dataDaCompraComps.month)];
        [dataDeVencimentoComps setYear:dataDaCompraComps.year];        
    }
    
    NSDate *vencimento = [calendario dateFromComponents:dataDeVencimentoComps];
    
    NSLog(@"(<) calculaVencimentoDaParcela: return = %@", vencimento);
    
    return vencimento;
}

//
// Cria as parcelas da compra passada como parametro com a opção de apagar
// ou não as parcelas já existentes
//
+(NSSet *)criarParcelasDaCompra:(Compra *)compra
     assumirAnterioresComoPagas:(BOOL)parcelasAntigasPagas
                      inContext:(NSManagedObjectContext *)context
{
    NSMutableSet *parcelas = [[ NSMutableSet alloc] initWithCapacity:[compra.qtdeTotalDeParcelas intValue]];
    
    NSError *error = nil;

    NSLog(@"(>) criarParcelasDaCompra: %@, %@, %@", compra, (parcelasAntigasPagas ? @"YES" : @"NO"), context);
    
    // Vamos criar as parcelas de acordo com o número passado.
    NSDecimalNumber *qtdeDecimal = [NSDecimalNumber decimalNumberWithDecimal:[compra.qtdeTotalDeParcelas decimalValue]];
    NSDecimalNumber *valorParcela = [compra.valorTotal decimalNumberByDividingBy:qtdeDecimal];
  
    for (int i=0; i < [compra.qtdeTotalDeParcelas intValue]; i++) {
                
        NSDate *vencimento;
        vencimento = [self calculaVencimentoDaParcela:compra.origem dataDaCompra:compra.dataDaCompra numDaParcela:i+1];
        
        // Avalia a a data da compra e assume parcelas anteriores como pagas
        NSString *estado = PARCELA_PENDENTE_PAGAMENTO;
        NSDate *hoje = [[NSDate alloc] init];
        // Se o vencimento é anterior a data de hoje...
        if ([[hoje earlierDate:vencimento] isEqualToDate:vencimento]) {
            if (parcelasAntigasPagas == YES) {
                // Vamos assumir a parcela como paga.
                estado = PARCELA_PAGA;
            } else {
                // De outro modo elas estão vencidas.
                estado = PARCELA_VENCIDA;
            }
        }
        
        // Vamos criar a parcela
        NSString *descricaoParcela = [@"Parcela " stringByAppendingFormat:@" %i de %i", i+1, [compra.qtdeTotalDeParcelas intValue]];
        Parcela *p = [Parcela novaParcelaComDescricao:descricaoParcela 
                                    eDataDeVencimento:vencimento 
                                            comEstado:estado 
                                     eNumeroDaParcela:[NSNumber numberWithInt:i+1] 
                                             comValor:valorParcela 
                                      pertenceACompra:compra
                                            inContext:context];

        [context save:(&error)];
        
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
        
        [parcelas addObject:p];

    }

    NSLog(@"(<) criarParcelasDaCompra: return = %@", parcelas);
 
    return parcelas;
}


//
// Apaga todas as parcelas da compra passada como parametro
//
+(void)apagarParcelasDaCompra:(Compra *)compra inContext:(NSManagedObjectContext *)context
{
    NSLog(@"(>) apagarParcelasDaCompra: %@", context);
    
    for (Parcela *p in compra.parcelas) {
        [context deleteObject:p];
        NSLog(@"(!) apagarParcelasDaCompra: deleted = %@", p);
    } 
    
    NSLog(@"(<) apagarParcelasDaCompra: ");

}


@end
