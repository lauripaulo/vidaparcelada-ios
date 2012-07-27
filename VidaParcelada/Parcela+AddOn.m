//
//  Parcela+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 23/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "Parcela+AddOn.h"
#import "VidaParceladaHelper.h"
#import "Compra+AddOn.h"

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
    NSString *mes = nil;
    NSString *mesAno = nil;
    [self willAccessValueForKey:@"dataVencimento"];
    NSDate *dataReal = [self dataVencimento];
    [self didAccessValueForKey:@"dataVencimento"];

    NSDateFormatter *dateFormatter;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM"];
    mes = [dateFormatter stringFromDate:dataReal];
    mes = [mes stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[mes substringToIndex:1] uppercaseString]];
    [dateFormatter setDateFormat:@"yyyy"];
    mesAno = [mes stringByAppendingFormat:@" de %@", [dateFormatter stringFromDate:dataReal]];
    
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
                           inContext:(NSManagedObjectContext *)context
{
    Parcela *novaParcela = nil;
    
    NSLog(@"(>) novaParcelaComDescricao: %@, %@, %@, %@, %@, %@, %@", descricao, dataDeVencimento, estado, numeroDaParcela, valor, compra.descricao, context);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
    request.predicate = [NSPredicate predicateWithFormat:@"descricao = %@ AND dataVencimento = %@ AND valor = %@", descricao, dataDeVencimento, valor];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    NSLog(@"(!) novaParcelaComDescricao: [matches count] = %d", [matches count]);
    
    // Se o objeto existir carrega o objeto para edição
    if (matches && [matches count] == 1) {
        novaParcela = [matches objectAtIndex:0];
        NSLog(@"(!) novaParcelaComDescricao: loaded = %@", novaParcela.descricao);
    }
    
    // Se existir mais de 1 objeto é uma situação de excessão e
    // devemos apagar os existentes e criar um novo
    if (matches && ([matches count] > 1)) {
        //
        // Apaga todos os itens errados...
        //
        for (Parcela *parcela in matches) {
            [context deleteObject:parcela];
            NSLog(@"(!) novaParcelaComDescricao: deleted = %@", parcela.descricao);
        }
        
        // ...e chama novamente de forma recursiva
        // este metodo de criação.
        novaParcela = [self novaParcelaComDescricao:descricao 
                                  eDataDeVencimento:dataDeVencimento 
                                          comEstado:estado 
                                   eNumeroDaParcela:numeroDaParcela 
                                           comValor:valor 
                                    pertenceACompra:compra 
                                          inContext:context];
        
    } else {
        //
        // Cria o novo objeto
        //
        if (!novaParcela) {
            novaParcela = [NSEntityDescription insertNewObjectForEntityForName:@"Parcela" inManagedObjectContext:context];
            NSLog(@"(!) novaParcelaComDescricao: new = %@", novaParcela.descricao);
        }
        novaParcela.descricao = descricao;
        novaParcela.dataVencimento = dataDeVencimento;
        novaParcela.estado = estado;
        novaParcela.numeroDaParcela = numeroDaParcela;
        novaParcela.compra = compra;
        novaParcela.valor = valor;
    }
    
    [context save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    NSLog(@"(<) novaParcelaComDescricao: return = %@", novaParcela.descricao);

    return novaParcela;
}


- (NSArray *) parcelasPendentesDoMes:(NSDate *)data
                           inContext:(NSManagedObjectContext *)context
{
    NSLog(@"(>) parcelasPendentesDoMes: %@, %@", data, context);

    // Vamos listar todas as parcelas
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Parcela"];
    
    // Uma parcela pendente tem o vencimento menor que a data passada
    // como parametro e está com seu pagamento pendente
    request.predicate = [NSPredicate predicateWithFormat:@"dataVencimento <= %@ AND estado = %@", data, PARCELA_PENDENTE_PAGAMENTO];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"descricao" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
 
    NSLog(@"(<) parcelasPendentesDoMes: return = %@", matches);

    return matches;
}


@end
