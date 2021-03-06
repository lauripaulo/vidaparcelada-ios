//
//  Compra+AddOn.m
//  VidaParcelada
//
//  Created by L. P. Laux on 23/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import "Compra+AddOn.h"
#import "Parcela+AddOn.h"
#import "Conta+AddOn.h"
#import "VidaParceladaHelper.h"
#import "VidaParceladaAppDelegate.h"
//
// Estados possíveis da compra
//
NSString * const COMPRA_PENDENTE_PAGAMENTO = @"Pendente";
NSString * const COMPRA_PAGAMENTO_PARCIAL = @"Parcial";
NSString * const COMPRA_PAGAMENTO_EFETUADO = @"Pago";

@implementation Compra (AddOn)

// Realiza uma varredura nas compras e atualiza os Core Data
+(void) atualizarComprasAposUpgrade;
{
    // Query no banco de dados, todas as compras, sem restrição.
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Compra"];
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    NSError *error = nil;
    NSArray *matches = [appDelegate.defaultContext executeFetchRequest:request error:&error];
    
    for (Compra *p in matches) {
        NSLog (@"Atualizando %@ ...", p.descricao);
        for (Parcela *parc in p.parcelas){
            NSLog (@" -> Parcela %@ ...", parc.descricao);
        }
        [appDelegate.defaultContext save:(&error)];
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
    }
    NSLog (@"Done");
    
}


+(Compra *)compraComDescricao:(NSString *)descricao
                  comDetalhes:(NSString *)detalhes
                 dataDaCompra:(NSDate *)data
                    comEstado:(NSString *)estado
               qtdeDeParcelas:(NSNumber *)parcelas
                   valorTotal:(NSDecimalNumber *)valorTotal
                     comConta:(Conta *)conta
   assumirAnterioresComoPagas:(BOOL)parcelasAntigasPagas
{ 
    //NSLog(@"(>) compraComDescricao: %@, %@, %@, %@, %@, %@, %@, %@, %@", descricao, detalhes, data, estado, parcelas, valorTotal, conta.descricao, (parcelasAntigasPagas ? @"YES" : @"NO"), context);
    
    //
    // Cria o novo objeto
    //
    Compra *novaCompra = nil;
    NSError *error = nil;
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    novaCompra = [NSEntityDescription insertNewObjectForEntityForName:@"Compra" inManagedObjectContext:appDelegate.defaultContext];
    
    NSLog(@"(!) compraComDescricao: new = %@", novaCompra.descricao);
    
    novaCompra.descricao = descricao;
    novaCompra.detalhes = detalhes;
    novaCompra.dataDaCompra = data;
    novaCompra.estado = estado;
    novaCompra.valorTotal = valorTotal;
    novaCompra.qtdeTotalDeParcelas = parcelas;
    novaCompra.origem = conta;
    
    [appDelegate.defaultContext save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    [self criarParcelasDaCompra:novaCompra assumirAnterioresComoPagas:parcelasAntigasPagas];
    
    NSLog(@"(<) compraComDescricao: return = %@", novaCompra.descricao);

    return novaCompra;
}

+(Conta *)retornaContaDefaultNoContexto
{
    Conta *conta = nil;
    
    //NSLog(@"(>) retornaContaDefaultNoContexto: %@", context);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // para a conta vamos selecionar o primeiro objeto da tabela conta
    // Query para encontrar o primeiro TipoConta e associar a conta que estamos criando
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
     
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSError *error = nil;
    NSArray *tipos = [appDelegate.defaultContext executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    // Itera nos resultados e retorna o a primeira conta preferencial, se não houver
    // retorna o primeiro resultado.
    for (Conta *c in tipos) {
        //NSLog(@"(!) retornaContaDefaultNoContexto: conta encontrada = %@", c.descricao);
        if ([c.preferencial isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            conta = c;
            break;
        }
    }

    // Se não houverem contas preferenciais escolhe a primeira disponível.
    if (!conta && tipos && [tipos count] > 0) {
       conta = [tipos objectAtIndex:0];
    } else {
        //NSLog(@"(!) retornaContaDefaultNoContexto: nenhuma conta encontrada.");
    }
    
    //NSLog(@"(<) retornaContaDefaultNoContexto: return = %@", conta.descricao);

    return conta;
}

+ (NSDate *)melhorDiaDeCompraDoMes:(Conta *)conta 
                         dataAtual:(NSDate *)data
{
    //NSLog(@"(>) melhorDiaDeCompraDoMes: %@, %@", conta.descricao, data);

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
   
    //NSLog(@"(<) melhorDiaDeCompraDoMes: return = %@", melhorDia);
    
    return melhorDia;
   
}

+ (NSDate *)calculaVencimentoDaParcela:(Conta *)conta 
                          dataDaCompra:(NSDate *)data 
                                 numDaParcela:(int)i
{
    //NSLog(@"(>) calculaVencimentoDaParcela: %@, %@, %d", conta.descricao, data, i);

    // Vamos precisar de um calendário
    // para calcular os vencimentos das parcelas
    NSCalendar *calendario = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *dataDaCompraComps = [calendario components:unitFlags fromDate:data];
    // Calculando o vencimento...
    NSDateComponents *dataDeVencimentoComps = [[NSDateComponents alloc] init];
    NSDate *melhorDiaDesteMes = [Compra melhorDiaDeCompraDoMes:conta dataAtual:data];
    
    if ([conta.diaDeVencimento intValue] < [conta.melhorDiaDeCompra intValue]) {
        // Se o vencimento for menor que o melhor dia significa que o vencimento esta no
        // mes seguinte ao melhor dia. Ex: Melhor dia 27, vencimento 04.
        if (dataDaCompraComps.day >= [conta.melhorDiaDeCompra intValue]) {
            // Se a Data da compra >= melhor dia significa que a fatura fechou e a compra sera computada
            // para o mes seguinte. No caso de vencimento < o melhor dia será em 2 meses.
            [dataDeVencimentoComps setDay:[conta.diaDeVencimento intValue]];
            [dataDeVencimentoComps setMonth:(dataDaCompraComps.month +i +1)];
            [dataDeVencimentoComps setYear:dataDaCompraComps.year];
        } else {
            // Se a Data da compra < melhor dia significa que a fatura está aberta e sera computada
            // para o proximo mes.
            [dataDeVencimentoComps setDay:[conta.diaDeVencimento intValue]];
            [dataDeVencimentoComps setMonth:(dataDaCompraComps.month +i)];
            [dataDeVencimentoComps setYear:dataDaCompraComps.year];
        }
    } else if ([[data laterDate:melhorDiaDesteMes] isEqualToDate:data] || [data isEqualToDate:melhorDiaDesteMes]) {
        // Vencimento >= melhor dia 
        // Se a compra for *durante* OU *depois* do melhor dia do mes
        // o vencimento será no próximo mês
        [dataDeVencimentoComps setDay:[conta.diaDeVencimento intValue]];
        [dataDeVencimentoComps setMonth:(dataDaCompraComps.month +i)];
        [dataDeVencimentoComps setYear:dataDaCompraComps.year];        
    } else {
        // Se for antes do melhor dia a data de vencimento é durante o 
        // mês atual
        [dataDeVencimentoComps setDay:[conta.diaDeVencimento intValue]];
        [dataDeVencimentoComps setMonth:(dataDaCompraComps.month + (i-1))];
        [dataDeVencimentoComps setYear:dataDaCompraComps.year];        
    }
    
    NSDate *vencimento = [calendario dateFromComponents:dataDeVencimentoComps];
    
    //NSLog(@"(<) calculaVencimentoDaParcela: return = %@", vencimento);
    
    return vencimento;
}

//
// Cria as parcelas da compra passada como parametro com a opção de apagar
// ou não as parcelas já existentes
//
+(NSSet *)criarParcelasDaCompra:(Compra *)compra
     assumirAnterioresComoPagas:(BOOL)parcelasAntigasPagas
{
    NSMutableSet *parcelas = [[ NSMutableSet alloc] initWithCapacity:[compra.qtdeTotalDeParcelas intValue]];
    
    NSError *error = nil;
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    //NSLog(@"(>) criarParcelasDaCompra: %@, %@, %@", compra.descricao, (parcelasAntigasPagas ? @"YES" : @"NO"), context);
    
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
        
        NSString *descricao = NSLocalizedString(@"parcela.nova.descricao", @"Parcela ");
        NSString *separador = NSLocalizedString(@"parcela.nova.separador", @"de");
        
        NSString *descricaoParcela = [descricao stringByAppendingFormat:@" %i %@ %i", i+1, separador, [compra.qtdeTotalDeParcelas intValue]];
        
        // Vamos criar a parcela
        Parcela *p = [Parcela novaParcelaComDescricao:descricaoParcela
                                    eDataDeVencimento:vencimento 
                                            comEstado:estado 
                                     eNumeroDaParcela:[NSNumber numberWithInt:i+1] 
                                             comValor:valorParcela 
                                      pertenceACompra:compra];

        [appDelegate.defaultContext save:(&error)];
        
        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
        
        [parcelas addObject:p];

    }

    //NSLog(@"(<) criarParcelasDaCompra: return = count(%d)", [parcelas count]);
 
    return parcelas;
}


//
// Apaga todas as parcelas da compra passada como parametro
//
+(void)apagarParcelasDaCompra:(Compra *)compra
{
    //NSLog(@"(>) apagarParcelasDaCompra: %@", context);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    for (Parcela *p in compra.parcelas) {
        [appDelegate.defaultContext deleteObject:p];
        //NSLog(@"(!) apagarParcelasDaCompra: deleted = %@", p.descricao);
    } 
    
    //NSLog(@"(<) apagarParcelasDaCompra: ");

}

+(int) quantidadeDeComprasComConta:(Conta *)conta
{
    //NSLog(@"(>) quantidadeDeCompras: %@, %@", context, (conta ? conta.descricao : nil));

    int count = 0;
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    
    // Somente restringe se a conta for válida
    if (conta) {
        request.predicate = [NSPredicate predicateWithFormat:@"conta = %@", conta.descricao];
    }

    NSError *error = nil;
    NSArray *matches = [appDelegate.defaultContext executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    if (matches && [matches count] > 0) {
        count = [matches count];
    }
    
    //NSLog(@"(<) quantidadeDeCompras: return = %d", count);
    
    return count;
}

@end
