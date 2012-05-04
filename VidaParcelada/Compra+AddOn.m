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
                    inContext:(NSManagedObjectContext *)context
{
    Compra *novaCompra = nil;
    
    NSLog(@"Criando Compra: descricao(%@) data:(%@) estado:(%@) parcelas:(%@) valor:(%@)",  descricao, data, estado, parcelas, valorTotal);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Compra"];
    request.predicate = [NSPredicate predicateWithFormat:@"descricao = %@ AND estado = %@ AND valorTotal = %@", descricao, estado, valorTotal];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Erro! Encontrado %i linhas com a descricao(%@)/data(%@)/valorTotal(%@). Apagar todos e recriar...", [matches count], descricao, data, valorTotal);
    } else if ([matches count] == 0) {
        NSLog(@"Não encontrado nenum registro para essa descricao, criando..."); 
        novaCompra = [NSEntityDescription insertNewObjectForEntityForName:@"Compra" inManagedObjectContext:context];
        novaCompra.descricao = descricao;
        novaCompra.dataDaCompra = data;
        novaCompra.estado = estado;
        novaCompra.valorTotal = valorTotal;
        novaCompra.qtdeTotalDeParcelas = parcelas;
        [self criarParcelasDaCompra:novaCompra inContext:context];
        
        // para a conta vamos selecionar o primeiro objeto da tabela conta
        // Query para encontrar o primeiro TipoConta e associar a conta que estamos criando
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
        request.sortDescriptors = [NSArray arrayWithObject:
                                   [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
        NSArray *tipos = [context executeFetchRequest:request error:&error];
        if (tipos && [tipos count] > 0) {
            novaCompra.origem = [tipos objectAtIndex:0];
        }
    } else {
        NSLog(@"Descricao já existe no banco de dados, retornando o objeto.");
        novaCompra = [matches lastObject];
    }

    
    return novaCompra;
}

//
// Cria as parcelas da compra passada como parametro com a opção de apagar
// ou não as parcelas já existentes
//
+(NSSet *)criarParcelasDaCompra:(Compra *)compra
                      inContext:(NSManagedObjectContext *)context
{
    NSMutableSet *parcelas = [[ NSMutableSet alloc] initWithCapacity:[compra.qtdeTotalDeParcelas intValue]];
    
    // Vamos precisar de um calendário
    // para calcular os vencimentos das parcelas
    NSCalendar *calendario = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dataDaCompraComps = [calendario components:unitFlags fromDate:compra.dataDaCompra];

    NSLog(@"Criando parcelas da compra(%@)", compra);
    
    // Vamos criar as parcelas de acordo com o número passado.
    NSDecimalNumber *qtdeDecimal = [NSDecimalNumber decimalNumberWithDecimal:[compra.qtdeTotalDeParcelas decimalValue]];
    NSDecimalNumber *valorParcela = [compra.valorTotal decimalNumberByDividingBy:qtdeDecimal];
  
    for (int i=0; i < [compra.qtdeTotalDeParcelas intValue]; i++) {
                
        // Calculando o vencimento adicionando 1 mes
        NSDateComponents *dataDeVencimentoComps = [[NSDateComponents alloc] init];
        [dataDeVencimentoComps setDay:[compra.origem.diaDeVencimento intValue]];
        [dataDeVencimentoComps setMonth:(dataDaCompraComps.month +i +1)];
        [dataDeVencimentoComps setYear:dataDaCompraComps.year];
        NSDate *vencimento = [calendario dateFromComponents:dataDeVencimentoComps];
        
        // Vamos criar a parcela
        NSString *descricaoParcela = [@"Parcela " stringByAppendingFormat:@" %i de %i", i, [compra.qtdeTotalDeParcelas intValue]];
        Parcela *p = [Parcela novaParcelaComDescricao:descricaoParcela 
                                    eDataDeVencimento:vencimento 
                                            comEstado:PARCELA_PENDENTE_PAGAMENTO 
                                     eNumeroDaParcela:[NSNumber numberWithInt:i] 
                                             comValor:valorParcela 
                                            inContext:context];

        [parcelas addObject:p];

    }

    
    return parcelas;
}


//
// Apaga todas as parcelas da compra passada como parametro
//
+(void)apagarParcelasDaCompra:(Compra *)compra
{
    NSLog(@"Apagando parcelas da compra(%@)", compra);

}


@end
