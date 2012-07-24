//
//  TipoConta+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 15/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "TipoConta+AddOn.h"
#import "VidaParceladaHelper.h"

@implementation TipoConta (AddOn)

+(TipoConta *)contaComNome:(NSString *)nome 
                eDescricao:(NSString *)descricao 
       identificadorDeTipo:(int)tipo
                 inContext:(NSManagedObjectContext *)context 
{
    TipoConta *tipoConta = nil;
    
    NSLog(@"(>) contaComNome: %@, %@, %d, %@", nome, descricao, tipo, context);
    
    // Query no banco de dados
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TipoConta"];
    request.predicate = [NSPredicate predicateWithFormat:@"nome = %@", nome];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nome" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
   
    NSLog(@"(!) contaComNome: [matches count] = %d", [matches count]);
    
    // Se o objeto existir carrega o objeto para edição
    if (matches && [matches count] == 1) {
        tipoConta = [matches objectAtIndex:0];
        NSLog(@"(!) contaComNome: loaded = %@", tipoConta.nome);
    }
    
    // Se existir mais de 1 objeto é uma situação de excessão e
    // devemos apagar os existentes e criar um novo
    if (matches && ([matches count] > 1)) {
        //
        // Apaga todos os itens errados...
        //
        for (TipoConta *tipo in matches) {
            [context deleteObject:tipo];
            NSLog(@"(!) contaComNome: deleted = %@", tipo.nome);
        }
        
        // ...e chama novamente de forma recursiva
        // este metodo de criação.
        tipoConta = [self contaComNome:nome 
                            eDescricao:descricao 
                   identificadorDeTipo:tipo 
                             inContext:context];
        
    } else {
        //
        // Cria o novo objeto
        //
        if (!tipoConta) {
            tipoConta = [NSEntityDescription insertNewObjectForEntityForName:@"TipoConta" inManagedObjectContext:context];
            NSLog(@"(!) contaComNome: new = %@", tipoConta.nome);
        }
        tipoConta.nome = nome;
        tipoConta.descricao = descricao;
        tipoConta.tipo = [NSNumber numberWithInt:tipo];
    }
    
    [context save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    NSLog(@"(<) contaComNome: return = %@", tipoConta.nome);

    return tipoConta;
}

@end
