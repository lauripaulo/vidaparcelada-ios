//
//  TipoConta+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 15/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "TipoConta+AddOn.h"

@implementation TipoConta (AddOn)

+(TipoConta *)contaComNome:(NSString *)nome eDescricao:(NSString *)descricao inContext:(NSManagedObjectContext *)context 
{
    TipoConta *tipo = nil;
    
    NSLog(@"Criando TipoConta: nome(%@) descricao:(%@)", nome, descricao);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
    request.predicate = [NSPredicate predicateWithFormat:@"nome = %@", nome];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Erro! Encontrado %i linhas com o nome(%@). Apagar todos e recriar...", [matches count], nome);
    } else if ([matches count] == 0) {
        NSLog(@"Não encontrado nenum registro para esse nome, criando..."); 
        tipo = [NSEntityDescription insertNewObjectForEntityForName:@"TipoConta" inManagedObjectContext:context];
        tipo.nome = nome;
        tipo.descricao = descricao;
    } else {
        NSLog(@"Nome já existe no banco de dados, retornando o objeto.");
        tipo = [matches lastObject];
    }
    
    return tipo;
}

- (void)prepareForDeletion
{
    
}

@end
