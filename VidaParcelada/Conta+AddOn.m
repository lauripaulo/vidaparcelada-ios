//
//  Conta+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 16/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Conta+AddOn.h"

@implementation Conta (AddOn)


+ (Conta *)contaComDescricao:(NSString *)descricao 
                   daEmpresa:(NSString *) empresa
          comVencimentoNoDia:(NSNumber *) diaDeVencimento
                   eJurosMes:(NSDecimalNumber *) jurosMes
              comLimiteTotal:(NSDecimalNumber *) limite
        comMelhorDiaDeCompra:(NSNumber *) melhorDiaDeCompra
                   inContext:(NSManagedObjectContext *)context
{
    Conta *conta = nil;
    
    NSLog(@"Criando conta: descricao(%@) empresa:(%@)", descricao, empresa);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.predicate = [NSPredicate predicateWithFormat:@"descricao = %@", descricao];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Erro! Encontrado %i linhas com a descricao(%@). Apagar todos e recriar...", [matches count], descricao);
    } else if ([matches count] == 0) {
        NSLog(@"Não encontrado nenhum registro para a descrição, criando..."); 
        conta = [NSEntityDescription insertNewObjectForEntityForName:@"Conta" inManagedObjectContext:context];
        conta.descricao = descricao;
        conta.empresa = empresa;
        conta.diaDeVencimento = diaDeVencimento;
        conta.jurosMes = jurosMes;
        conta.limite = limite;
        conta.melhorDiaDeCompra = melhorDiaDeCompra;
        conta.compras = nil; // conta nova não tem compras...
        
        // Query para encontrar o primeiro TipoConta e associar a conta que estamos criando
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
        request.sortDescriptors = [NSArray arrayWithObject:
                                   [NSSortDescriptor sortDescriptorWithKey:@"tipo" ascending:YES]];
        NSArray *tipos = [context executeFetchRequest:request error:&error];
        if (tipos && [tipos count] > 0) {
            conta.tipo = [tipos objectAtIndex:0];
        }
    } else {
        NSLog(@"Nome já existe no banco de dados, retornando o objeto.");
        conta = [matches lastObject];
    }
    
    [context save:(&error)];
    
    return conta;
}

+ (NSArray *)contasCadastradasUsandoContext:(NSManagedObjectContext *)context
{    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Conta"];
    request.sortDescriptors = [NSArray arrayWithObject:
                               [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES 
                                                              selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    NSLog(@"Trazendo todas as contas cadastradas no momento:(%@)", matches);

    return matches;
}


@end
