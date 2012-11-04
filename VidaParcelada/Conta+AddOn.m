//
//  Conta+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 16/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import "Conta+AddOn.h"
#import "VidaParceladaHelper.h"
#import "TipoConta+AddOn.h"
#import "VidaParceladaAppDelegate.h"

@implementation Conta (AddOn)


+ (Conta *)contaComDescricao:(NSString *)descricao 
                   daEmpresa:(NSString *) empresa
          comVencimentoNoDia:(NSNumber *) diaDeVencimento
                   eJurosMes:(NSDecimalNumber *) jurosMes
              comLimiteTotal:(NSDecimalNumber *) limite
        comMelhorDiaDeCompra:(NSNumber *) melhorDiaDeCompra
          cartaoPreferencial:(BOOL)preferencial
                comTipoConta:(TipoConta *)tipoConta
{
    Conta *novaConta = nil;
    
    //NSLog(@"(>) contaComDescricao: %@, %@, %@, %@, %@, %@, %@, %@, %@", descricao, empresa, diaDeVencimento, jurosMes, limite, melhorDiaDeCompra, (preferencial ? @"YES" : @"NO"), tipoConta.nome, context);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.predicate = [NSPredicate predicateWithFormat:@"descricao = %@ AND empresa = %@", descricao, empresa];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [appDelegate.defaultContext executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];

    //NSLog(@"(!) contaComDescricao: [matches count] = %d", [matches count]);
    
    // Se o objeto existir carrega o objeto para edição
    if (matches && [matches count] == 1) {
        novaConta = [matches objectAtIndex:0];
        //NSLog(@"(!) contaComDescricao: loaded = %@", novaConta.descricao);
    }
    
    // Se existir mais de 1 objeto é uma situação de excessão e
    // devemos apagar os existentes e criar um novo
    if (matches && ([matches count] > 1)) {
        //
        // Apaga todos os itens errados...
        //
        for (Conta *conta in matches) {
            [appDelegate.defaultContext deleteObject:conta];
            //NSLog(@"(!) contaComDescricao: deleted = %@", conta.descricao);
        }
    
        // ...e chama novamente de forma recursiva
        // este metodo de criação.
        novaConta = [self contaComDescricao:descricao
                              daEmpresa:empresa 
                     comVencimentoNoDia:diaDeVencimento 
                              eJurosMes:jurosMes 
                         comLimiteTotal:limite 
                   comMelhorDiaDeCompra:melhorDiaDeCompra 
                     cartaoPreferencial:preferencial
                           comTipoConta:tipoConta];
    
    } else  {
        //
        // Cria o novo objeto
        //
        if (!novaConta) {
            novaConta = [NSEntityDescription insertNewObjectForEntityForName:@"Conta" inManagedObjectContext:appDelegate.defaultContext];
            novaConta.compras = nil; // conta nova não tem compras...
            //NSLog(@"(!) contaComDescricao: new = %@", novaConta.descricao);
        }
        novaConta.tipo = tipoConta;
        novaConta.descricao = descricao;
        novaConta.empresa = empresa;
        novaConta.diaDeVencimento = diaDeVencimento;
        novaConta.jurosMes = jurosMes;
        novaConta.limite = limite;
        novaConta.melhorDiaDeCompra = melhorDiaDeCompra;
        // maneira de colocar BOOLs no coredata
        novaConta.preferencial = [NSNumber numberWithBool:preferencial];
        
 }
    
    [appDelegate.defaultContext save:(&error)];

    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    //NSLog(@"(<) contaComDescricao: return = %@", novaConta.descricao);

    return novaConta;
}

+ (TipoConta *) retornaTipoContaPadraoNoContexto
{
    //NSLog(@"(>) retornaTipoContaPadraoNoContexto: %@", context);

    NSError *error = nil;
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // Query para encontrar o primeiro TipoConta e associar a conta que estamos criando
    NSFetchRequest *tipoRequest = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
    tipoRequest.predicate = [NSPredicate predicateWithFormat:@"nome = 'Cartão de crédito' "];
    tipoRequest.sortDescriptors = [NSArray arrayWithObject:
                                   [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSArray *tipos = [appDelegate.defaultContext executeFetchRequest:tipoRequest error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    if (tipos && [tipos count] > 0) {
        TipoConta *tipo = [tipos objectAtIndex:0];
        //NSLog(@"(<) retornaTipoContaPadraoNoContexto: return = %@", tipo.descricao);
        return tipo;
    }
    
    //NSLog(@"(<) retornaTipoContaPadraoNoContexto: return = nil");

    return nil;

}

+ (NSArray *)contasCadastradasUsandoContext
{    
    //NSLog(@"(>) contasCadastradasUsandoContext: %@", context);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSError *error = nil;
    NSArray *matches = [appDelegate.defaultContext executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];

    //NSLog(@"(<) contaComDescricao: return = %@", matches);

    return matches;
}

// Retorna a quantidade de compras cadastradas nesse momento
// na base de dados
+(int) quantidadeDeContas
{
    //NSLog(@"(>) quantidadeDeContas: %@", context);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    int count = 0;
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    
    NSError *error = nil;
    NSArray *matches = [appDelegate.defaultContext executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    if (matches && [matches count] > 0) {
        count = [matches count];
    }
    
    //NSLog(@"(<) quantidadeDeContas: %d", count);

    return count;
}

+(void)removeContaTotalmente:(Conta *)conta
{
    //NSLog(@"(>) removeContaTotalmente: %@", conta.descricao);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    [appDelegate.defaultContext deleteObject:conta];
    
    NSError *error = nil;
    [appDelegate.defaultContext save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    //NSLog(@"(<) removeContaTotalmente: ");
}

// Verifica todos as contas existentes para saber se a data
// passada como parametro é a data de vencimento do cartão
// ou o melhor dia, dependendo dos parametros passados.
// Retorna um array de cartões que atendem a essa restrição,
// se nenhum estiver vencendo o retorno será nil.
+ (NSArray *)verificaDataRetornandoContas:(NSDate *)data
                     comparandoVencimento:(BOOL)vencimento
                      comparandoMelhorDia:(BOOL)melhorDia
{
    //NSLog(@"(>) verificaDataRetornandoContas - %@, %@, %@, %@", data, context, (vencimento ? @"YES" : @"NO"), (melhorDia ? @"YES" : @"NO"));
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];

    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // Para transformar a data em dia/string
    NSDateFormatter *dateFormatter;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d"];
    
    // Para transformar o dia/string em numero e comparar
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];

    // Dia em string e numero
    NSString *dataString = [dateFormatter stringFromDate:data];
    NSNumber *diaParam = [nf numberFromString:dataString];
    //NSLog(@"(!) verificaDataRetornandoContas - diaParam = %@", diaParam);
   
    // precisamos listar todas as contas
    NSArray *contas = [Conta contasCadastradasUsandoContext:appDelegate.defaultContext];
    
    // Iterar e descobrir se alguma delas tem a data de vencimento
    // igual a passada.
    for (Conta *candidato in contas){

        // Para facilitar podemos converter as duas para o mesmo formato,
        // na verdade precisamos apenas do dia, como um numero basta para
        // a nossa comparação.
        if (vencimento) {
            if ([diaParam isEqualToNumber:candidato.diaDeVencimento]) {
                [result addObject:candidato];
                //NSLog(@"(!) verificaDataRetornandoContas - found diaDeVencimento = %@", candidato.diaDeVencimento);
            }
        }
        if (melhorDia) {
            // Avalia o melhor dia apenas se ele for diferente do vencimento.
            if ([candidato.diaDeVencimento isEqualToNumber:candidato.melhorDiaDeCompra]) {
                //NSLog(@"(!) verificaDataRetornandoContas - found melhorDiaDeCompra == diaDeVencimento");
            } else {
                if ([diaParam isEqualToNumber:candidato.melhorDiaDeCompra]) {
                    [result addObject:candidato];
                    //NSLog(@"(!) verificaDataRetornandoContas - found melhorDiaDeCompra = %@", candidato.melhorDiaDeCompra);
                }
            }
        }
        
    }
    
    //NSLog(@"(<) verificaDataRetornandoContas - result = count(%u)", [result count]);

    return [result copy];
}

@end
