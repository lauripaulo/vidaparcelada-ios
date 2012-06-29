//
//  VidaParceladaHelper.m
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 21/04/12.
//  Copyright (c) 2012 Oriba Apps. All rights reserved.
//

#import "VidaParceladaHelper.h"


@implementation VidaParceladaHelper

+ (NSString *)removeCharsNaoNumericos:(NSString *)stringAtual
{
    // regex para aceitar apenas numeros
    NSString *regex = @"[0-9]*";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    // removendo a marcação atual do campo
    int tamanhoCampo = [stringAtual length];
    NSString *buffer = @"";
    
    for (int i=0; i<tamanhoCampo; i++) {
        NSString *digit = [stringAtual substringWithRange:NSMakeRange(i, 1)];        
        //Verifica se é um numero, se não for consome o digito
        if (![digit isEqualToString:@" "] && [regextest evaluateWithObject:digit]) {
            buffer = [buffer stringByAppendingString:digit];
        }
    }
    return buffer;
}

+ (void)executarBackspaceNoCampo:(UITextField *)aTextField range:(NSRange)range novoDigito:(NSString *)novoDigito
{
    // Backspace
    if ([novoDigito length] == 0 && [aTextField.text length] > 0) {
        int textLen = [aTextField.text length] - 1;
        
        if (range.location == textLen) {
            // cursor no final do campo
            aTextField.text = [aTextField.text substringToIndex:textLen];
        } else {
            //
            // cursor no meio do campo
            // ATENÇÃO!!! Exemplo de como adicionar caracteres do cursor usando *range*
            //
            NSRange rangeInicial = NSMakeRange(0, range.location);
            NSRange rangeFinal = NSMakeRange(range.location+1, [aTextField.text length] - range.location -1);
            NSString *parte1 = [aTextField.text substringWithRange:rangeInicial];
            NSString *parte2 = [aTextField.text substringWithRange:rangeFinal];
            aTextField.text = [parte1 stringByAppendingString:parte2];
        }
        
        NSLog(@"aTextField.text +backspace=%@", aTextField.text);
    }
}

+ (void)inserirDigitoNoCampo:(UITextField *)aTextField range:(NSRange)range novoDigito:(NSString *)novoDigito
{
    // regex para aceitar apenas numeros
    NSString *regex = @"[0-9]*";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    // ignora não numericos
    if (![regextest evaluateWithObject:novoDigito]) {
        return;
    }

    if ([novoDigito length] > 0 && range.location < [aTextField.text length]) {
        int textLen = [aTextField.text length] - 1;
        
        if (range.location == textLen) {
            // cursor no final do campo
            aTextField.text = [aTextField.text substringToIndex:textLen];
        } else {
            //
            // cursor no meio do campo
            // ATENÇÃO!!! Exemplo de como remover o caracter do cursor usando *range*
            //
            NSRange rangeInicial = NSMakeRange(0, range.location);
            NSRange rangeFinal = NSMakeRange(range.location, [aTextField.text length] - range.location -1);
            NSString *parte1 = [aTextField.text substringWithRange:rangeInicial];
            NSString *parte2 = [aTextField.text substringWithRange:rangeFinal];
            aTextField.text = [parte1 stringByAppendingString:novoDigito];
            aTextField.text = [aTextField.text stringByAppendingString:parte2];

        }
        
        NSLog(@"aTextField.text +backspace=%@", aTextField.text);
    }
}


+ (void)formataValor:(UITextField*)aTextField 
          novoDigito:(NSString*)novoDigito 
            comRange:(NSRange)range 
     usandoFormatter:(NSNumberFormatter *)formatter
      eQtdeDeDigitos:(int)qtdeDigitos
{
    NSLog(@"formatInput: aTextField=%@ novoDigito=%@, range=[Location=%i, Lenght:%i]", aTextField.text, novoDigito, range.location, range.length);

    [self executarBackspaceNoCampo:aTextField range:range novoDigito:novoDigito];
    [self inserirDigitoNoCampo:aTextField range:range novoDigito:novoDigito];

    // regex para aceitar apenas numeros
    NSString *regex = @"[0-9]*";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    NSString *buffer;
    buffer = [self removeCharsNaoNumericos:aTextField.text];
    
    // OK, agora verificamos se o valor adicionado é um numero, adicionamos ao final
    // do buffer para que ele seja formatado corretamente depois.
    
    NSLog(@"buffer:%@", buffer);
        
    // Campo cheio, consome o novo digito
    if ([buffer length] == qtdeDigitos) { // Se o campo já tem o tamanho da mascara o caracter é ignorado.
        NSLog(@"Campo cheio.");
    } else if (![regextest evaluateWithObject:novoDigito]) {
        NSLog(@"Digito invalido.");
    } else {
        buffer = [buffer stringByAppendingString:novoDigito];
        NSString *decimalString = @"";

        // parte decimal
        if ([buffer length] == 1) {
            decimalString = [decimalString stringByAppendingFormat:@"0.0%@", buffer];
        } else if ([buffer length] == 2) {
            decimalString = [decimalString stringByAppendingFormat:@"0.%@", buffer];
        } else {
            int pontoDecimal = [buffer length] -2;
            NSString *bufferDecimal = [buffer substringFromIndex:pontoDecimal];
            NSString *bufferCentenas = [buffer substringToIndex:pontoDecimal];
            decimalString = [decimalString stringByAppendingFormat:@"%@.%@", bufferCentenas, bufferDecimal];
        }
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:decimalString];
        aTextField.text = [formatter stringFromNumber:number];
        
    }

}


//This method is responsible for add mask characters properly
+ (void)formatInput:(UITextField*)aTextField string:(NSString*)aString range:(NSRange)aRange withMask:(NSString *)mask
{
    
    NSLog(@"");
    NSLog(@"formatInput: aString=%@, aRange=[Location=%i, Lenght:%i]", aString, aRange.location, aRange.length);
    NSLog(@"mask=%@", mask);
    NSLog(@"textfield.text=%@", aTextField.text);

    int maskLength = [mask length];
    
    if (([aTextField.text length] == maskLength) && [aString length] > 0) {
        return;
    }
    
    //If the user has started typing text on UITextField the formatting method must be called
    else if ([aTextField.text length] || aRange.location == 0) {
       
        if (aString) {
            if(! [aString isEqualToString:@""]) {
                //Copying the contents of UITextField to an variable to add new chars later
                NSString* value = aTextField.text;
                
                NSString* formattedValue = value;
                
                //Make sure to retrieve the newly entered char on UITextField
                aRange.length = 1;
                
                NSString* _mask = [mask substringWithRange:aRange];
                
                //Checking if there's a char mask at current position of cursor
                if (_mask != nil) {
                    NSString *regex = @"[0-9]*";
                    
                    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                    //Checking if the character at this position isn't a digit 
                    if (! [regextest evaluateWithObject:_mask]) {
                        //If the character at current position is a special char this char must be appended to the user entered text
                        formattedValue = [formattedValue stringByAppendingString:_mask];
                    } 
                    
                    if (aRange.location + 1 < [mask length]) {
                        _mask = [mask substringWithRange:NSMakeRange(aRange.location + 1, 1)];
                        if([_mask isEqualToString:@" "])
                            formattedValue = [formattedValue stringByAppendingString:_mask];
                    }
                }
                //Adding the user entered character
                formattedValue = [formattedValue stringByAppendingString:aString];
                
                //Refreshing UITextField value       
                aTextField.text = formattedValue;
            } else {
                // Backspace
                int textLen = [aTextField.text length] - 1;
                NSString *text = [aTextField.text substringToIndex:textLen];
                aTextField.text = text;
            }
        }
    }
    
    NSLog(@"textfield.text(final)=%@", aTextField.text);
    NSLog(@"----------------------------------------------------------------------------------");

}

+ (NSDecimalNumber *) retornaLimiteDeGastoGlobal
{
    NSDecimalNumber *valorFinal = [[NSDecimalNumber alloc] initWithInt:0];
    
    NSString *currentStringVal = [VidaParceladaHelper retornaLimiteDeGastoGlobalStr];
 
    NSNumberFormatter *valorFormatter;
    valorFormatter = [[NSNumberFormatter alloc] init];
    [valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    NSNumber *valor;
    valor = [valorFormatter numberFromString:currentStringVal];
    valorFinal = [NSDecimalNumber decimalNumberWithString:[valor stringValue]];
    NSLog (@"retornaLimiteDeGastoGlobal - objetivo=%@(DecimalNumber)", valorFinal);

    return valorFinal;
}


+ (NSString *) retornaLimiteDeGastoGlobalStr
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *currentStringVal = [defaults objectForKey:@"objetivo"];
    NSLog (@"retornaLimiteDeGastoGlobalStr - objetivo=%@(str)", currentStringVal);
    
    return currentStringVal;
}


+ (void) salvaLimiteDeGastoGlobalStr:(NSString *)total
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:total forKey:@"objetivo"];
    [defaults synchronize];
    NSLog (@"salvaLimiteDeGastoGlobal - objetivo=%@", total);
}

+ (void) trataErro:(NSError *)error
{
    if (error) {
        // Loga informações do erro
        NSLog (@"(!) Erro encontrado - NSError code: %d", error.code);
        NSLog (@"(!) - Description .......: %@", error.localizedDescription);
        NSLog (@"(!) - FailureReason .....: %@", error.localizedFailureReason);
        NSLog (@"(!) - RecoveryOptions ...: %@", error.localizedRecoveryOptions);
        NSLog (@"(!) - RecoverySuggestion : %@", error.localizedRecoverySuggestion);
        
        // tratamento específico para cada tipo de erro
               
    } else {
        NSLog (@"(_) Ok");
    }
}

@end