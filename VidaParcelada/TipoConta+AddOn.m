//
//  TipoConta+AddOn.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 15/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import "TipoConta+AddOn.h"
#import "VidaParceladaHelper.h"
#import "VidaParceladaAppDelegate.h"

@implementation TipoConta (AddOn)

+(TipoConta *)contaComNome:(NSString *)nome 
                eDescricao:(NSString *)descricao 
       identificadorDeTipo:(int)tipo
{
    TipoConta *tipoConta = nil;
    
    //NSLog(@"(>) contaComNome: %@, %@, %d, %@", nome, descricao, tipo, context);
    
    // Delegate com o defaultContext e defaultDatabase
    VidaParceladaAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    NSError *error = nil;
    //
    // Cria o novo objeto
    //
    if (!tipoConta) {
        tipoConta = [NSEntityDescription insertNewObjectForEntityForName:@"TipoConta" inManagedObjectContext:appDelegate.defaultContext];
        //NSLog(@"(!) contaComNome: new = %@", tipoConta.nome);
    }
    tipoConta.nome = nome;
    tipoConta.descricao = descricao;
    tipoConta.tipo = [NSNumber numberWithInt:tipo];
    
    [appDelegate.defaultContext save:(&error)];
    
    // Tratamento de errors
    [VidaParceladaHelper trataErro:error];
    
    //NSLog(@"(<) contaComNome: return = %@", tipoConta.nome);
    
    return tipoConta;
}

@end
