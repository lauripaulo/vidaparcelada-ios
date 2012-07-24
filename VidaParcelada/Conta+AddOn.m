//
//  Conta+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 16/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Conta+AddOn.h"
#import "VidaParceladaHelper.h"

@implementation Conta (AddOn)


+ (Conta *)contaComDescricao:(NSString *)descricao 
                   daEmpresa:(NSString *) empresa
          comVencimentoNoDia:(NSNumber *) diaDeVencimento
                   eJurosMes:(NSDecimalNumber *) jurosMes
              comLimiteTotal:(NSDecimalNumber *) limite
        comMelhorDiaDeCompra:(NSNumber *) melhorDiaDeCompra
          cartaoPreferencial:(BOOL)preferencial
                   inContext:(NSManagedObjectContext *)context
{
    Conta *novaConta = nil;
    
    NSLog(@"(>) contaComDescricao: %@, %@, %@, %@, %@, %@, %@, %@", descricao, empresa, diaDeVencimento, jurosMes, limite, melhorDiaDeCompra, (preferencial ? @"YES" : @"NO"), context);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.predicate = [NSPredicate predicateWithFormat:@"descricao = %@", descricao];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];

    NSLog(@"(!) contaComDescricao: [matches count] = %d", [matches count]);
    
    // Se o objeto existir carrega o objeto para edição
    if (matches && [matches count] == 1) {
        novaConta = [matches objectAtIndex:0];
        NSLog(@"(!) contaComDescricao: loaded = %@", novaConta.descricao);
    }
    
    // Se existir mais de 1 objeto é uma situação de excessão e
    // devemos apagar os existentes e criar um novo
    if (matches && ([matches count] > 1)) {
        //
        // Apaga todos os itens errados...
        //
        for (Conta *conta in matches) {
            [context deleteObject:conta];
            NSLog(@"(!) contaComDescricao: deleted = %@", conta.descricao);
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
                              inContext:context];
    
    } else  {
        //
        // Cria o novo objeto
        //
        if (!novaConta) {
            novaConta = [NSEntityDescription insertNewObjectForEntityForName:@"Conta" inManagedObjectContext:context];
            novaConta.compras = nil; // conta nova não tem compras...
            NSLog(@"(!) contaComDescricao: new = %@", novaConta.descricao);
        }
        novaConta.descricao = descricao;
        novaConta.empresa = empresa;
        novaConta.diaDeVencimento = diaDeVencimento;
        novaConta.jurosMes = jurosMes;
        novaConta.limite = limite;
        novaConta.melhorDiaDeCompra = melhorDiaDeCompra;
        // maneira de colocar BOOLs no coredata
        novaConta.preferencial = [NSNumber numberWithBool:preferencial];
        
        // Query para encontrar o primeiro TipoConta e associar a conta que estamos criando
        NSFetchRequest *tipoRequest = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
        tipoRequest.predicate = [NSPredicate predicateWithFormat:@"nome = 'Cartão de crédito' "];
        tipoRequest.sortDescriptors = [NSArray arrayWithObject:
                                       [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        NSArray *tipos = [context executeFetchRequest:tipoRequest error:&error];

        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
        
        if (tipos && [tipos count] > 0) {
            novaConta.tipo = [tipos objectAtIndex:0];
        }
    } 
    
    [context save:(&error)];

    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    NSLog(@"(<) contaComDescricao: return = %@", novaConta.descricao);

    return novaConta;
}

+ (NSArray *)contasCadastradasUsandoContext:(NSManagedObjectContext *)context
{    
    NSLog(@"(>) contasCadastradasUsandoContext: %@", context);

    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];

    NSLog(@"(<) contaComDescricao: return = %@", matches);

    return matches;
}

// Retorna a quantidade de compras cadastradas nesse momento
// na base de dados
+(int) quantidadeDeContas:(NSManagedObjectContext *)context 
{
    NSLog(@"(>) quantidadeDeContas: %@", context);

    int count = 0;
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    if (matches && [matches count] > 0) {
        count = [matches count];
    }
    
    NSLog(@"(<) quantidadeDeContas: %d", count);

    return count;
}


@end
