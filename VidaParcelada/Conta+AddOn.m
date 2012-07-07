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
    Conta *conta = nil;
    
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

    if (!matches || ([matches count] > 0)) {
        NSLog(@"(!) contaComDescricao: [matches count] = %d", [matches count]);
        //
        // Apaga todos os itens errados...
        //
        for (Conta *conta in matches) {
            [context deleteObject:conta];
            NSLog(@"(!) contaComDescricao: deleted = %@", conta);
        }
    
        // ...e chama novamente de forma recursiva
        // este metodo de criação.
        conta = [self contaComDescricao:descricao 
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
        conta = [NSEntityDescription insertNewObjectForEntityForName:@"Conta" inManagedObjectContext:context];
        conta.descricao = descricao;
        conta.empresa = empresa;
        conta.diaDeVencimento = diaDeVencimento;
        conta.jurosMes = jurosMes;
        conta.limite = limite;
        conta.melhorDiaDeCompra = melhorDiaDeCompra;
        // maneira de colocar BOOLs no coredata
        conta.preferencial = [NSNumber numberWithBool:preferencial];
        conta.compras = nil; // conta nova não tem compras...
        
        // Query para encontrar o primeiro TipoConta e associar a conta que estamos criando
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
        request.sortDescriptors = [NSArray arrayWithObject:
                                   [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES]];
        NSArray *tipos = [context executeFetchRequest:request error:&error];

        // Tratamento de errors
        [VidaParceladaHelper trataErro:error];
        
        if (tipos && [tipos count] > 0) {
            conta.tipo = [tipos objectAtIndex:0];
        }
    } 
    
    [context save:(&error)];

    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    NSLog(@"(<) contaComDescricao: return = %@", conta);

    return conta;
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


@end
