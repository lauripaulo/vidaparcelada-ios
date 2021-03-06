//
//  Parcela+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 23/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import "Parcela+AddOn.h"
#import "VidaParceladaHelper.h"
#import "Compra+AddOn.h"
#import "VidaParceladaHelper.h"
#import "VidaParceladaAppDelegate.h"

//
// Estados possíveis da compra
//
NSString * const PARCELA_PENDENTE_PAGAMENTO = @"Pendente";
NSString * const PARCELA_PAGA = @"Paga"; 
NSString * const PARCELA_VENCIDA = @"Vencida"; 

@implementation Parcela (AddOn)

// gera o mes e ano atual para uso na tela de agrupamento.
- (NSString *)tMesAno
{
    NSString *mesAno = nil;
    [self willAccessValueForKey:@"dataVencimento"];
    NSDate *dataReal = [self dataVencimento];
    [self didAccessValueForKey:@"dataVencimento"];

    mesAno = [VidaParceladaHelper formataMesParaTopCell:dataReal];
    
    return mesAno;
}

//
// Cria uma nova parcela
//
+ (Parcela *)novaParcelaComDescricao:(NSString *)descricao
                   eDataDeVencimento:(NSDate *)dataDeVencimento
                           comEstado:(NSString *)estado
                    eNumeroDaParcela:(NSNumber *)numeroDaParcela
                            comValor:(NSDecimalNumber *)valor
                     pertenceACompra:(Compra *)compra
{
    Parcela *novaParcela = nil;
    
    //NSLog(@"(>) novaParcelaComDescricao: %@, %@, %@, %@, %@, %@, %@", descricao, dataDeVencimento, estado, numeroDaParcela, valor, compra.descricao, context);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    NSError *error = nil;
    
    //NSLog(@"(!) novaParcelaComDescricao: [matches count] = %d", [matches count]);
    
    //
    // Cria o novo objeto
    //
    if (!novaParcela) {
        novaParcela = [NSEntityDescription insertNewObjectForEntityForName:@"Parcela" inManagedObjectContext:appDelegate.defaultContext];
        //NSLog(@"(!) novaParcelaComDescricao: new = %@", novaParcela.descricao);
    }
    novaParcela.descricao = descricao;
    novaParcela.dataVencimento = dataDeVencimento;
    novaParcela.estado = estado;
    novaParcela.numeroDaParcela = numeroDaParcela;
    novaParcela.compra = compra;
    novaParcela.valor = valor;
    
    [appDelegate.defaultContext save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    //NSLog(@"(<) novaParcelaComDescricao: return = %@", novaParcela.descricao);

    return novaParcela;
}


+ (NSArray *) parcelasPendentesDoMes:(NSDate *)data
                            eDaConta:(Conta *)conta
{
    //NSLog(@"(>) parcelasPendentesDoMes: '%@', '%@', '%@'", data, conta.descricao, context);

    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // Vamos listar todas as parcelas
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
    
    NSDate *inicioDoMes = [VidaParceladaHelper retornaPrimeiroDiaDoMes:data];
    NSDate *fimDoMes = [VidaParceladaHelper retornaUltimoDiaDoMes:data];
    
    if (conta) {
        request.predicate = [NSPredicate predicateWithFormat:@"estado = %@ AND compra.origem = %@ AND (dataVencimento >= %@) AND (dataVencimento <= %@)", PARCELA_PENDENTE_PAGAMENTO, conta, inicioDoMes, fimDoMes];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"estado = %@ AND (dataVencimento >= %@) AND (dataVencimento <= %@)", PARCELA_PENDENTE_PAGAMENTO, inicioDoMes, fimDoMes];
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [appDelegate.defaultContext executeFetchRequest:request error:&error];

    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
 
    //NSLog(@"(<) parcelasPendentesDoMes: return = %d", [matches count]);

    return matches;
}


+ (NSDecimalNumber *) calculaValorTotalDasParcelas:(NSArray *)parcelas
{
    //NSLog(@"(>) calculaValorTotalDasParcelas: %d", [parcelas count]);

    NSDecimalNumber *valorTotal = [[NSDecimalNumber alloc] initWithInt:0];
    
    for (Parcela *parc in parcelas) {
        valorTotal = [valorTotal decimalNumberByAdding:parc.valor];
    }
    
    //NSLog(@"(<) parcelasPendentesDoMes: return = %@", valorTotal);
    
    return valorTotal;
}


+ (int)pagaListaDeParcelas:(NSArray *)parcelas
{
    //NSLog(@"(>) pagaListaDeParcelas: %d", [parcelas count]);
    
    NSEnumerator *e = [parcelas objectEnumerator];
    id object;
    int i = 0;
    while (object = [e nextObject]) {
        Parcela *parcela = (Parcela *)object;
        if (![parcela.estado isEqual:PARCELA_PAGA]) {
            parcela.estado = PARCELA_PAGA;
            i++;
            //NSLog(@"(!) pagaListaDeParcelas: parcela da compra = %@", parcela.compra.descricao);
        }
    }
    
    //NSLog(@"(<) pagaListaDeParcelas: return = %d", i);
    
    return i;
}

@end
