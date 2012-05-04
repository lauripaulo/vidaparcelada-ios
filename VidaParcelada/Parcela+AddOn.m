//
//  Parcela+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 23/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Parcela+AddOn.h"

//
// Estados possíveis da compra
//
NSString * const PARCELA_PENDENTE_PAGAMENTO = @"Pendente";
NSString * const PARCELA_PAGA = @"Paga"; 
NSString * const PARCELA_VENCIDA = @"Vencida"; 

@implementation Parcela (AddOn)

//
// Cria uma nova parcela
//
+ (Parcela *)novaParcelaComDescricao:(NSString *)descricao
                   eDataDeVencimento:(NSDate *)dataDeVencimento
                           comEstado:(NSString *)estado
                    eNumeroDaParcela:(NSNumber *)numeroDaParcela
                            comValor:(NSDecimalNumber *)valor
                           inContext:(NSManagedObjectContext *)context
{
    Parcela *novaParcela = nil;
    
    NSLog(@"Criando Parcela: descricao(%@) dataDeVencimento:(%@) estado:(%@) numeroDaParcela:(%@) valor:(%@)",  descricao, dataDeVencimento, estado, numeroDaParcela, valor);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
    request.predicate = [NSPredicate predicateWithFormat:@"descricao = %@ AND dataVencimento = %@ AND valor = %@", descricao, dataDeVencimento, valor];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Erro! Encontrado %i linhas com o nome(%@). Apagar todos e recriar...", [matches count], descricao);
    } else if ([matches count] == 0) {
        NSLog(@"Não encontrado nenum registro para essa descricao, criando..."); 
        novaParcela = [NSEntityDescription insertNewObjectForEntityForName:@"Parcela" inManagedObjectContext:context];
        novaParcela.descricao = descricao;
        novaParcela.dataVencimento = dataDeVencimento;
        novaParcela.estado = estado;
        novaParcela.numeroDaParcela = numeroDaParcela;
    } else {
        NSLog(@"Descricao já existe no banco de dados, retornando o objeto.");
        novaParcela = [matches lastObject];
    }
    
    return novaParcela;
}

@end
