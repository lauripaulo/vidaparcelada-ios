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
    //NSLog (@"(>) removeCharsNaoNumericos: %@", stringAtual);
    
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
    
    //NSLog (@"(<) removeCharsNaoNumericos: return = %@", buffer);
    
    return buffer;
}

+ (void)executarBackspaceNoCampo:(UITextField *)aTextField 
                           range:(NSRange)range 
                      novoDigito:(NSString *)novoDigito
{
    //NSLog (@"(>) executarBackspaceNoCampo: %@, %@, %@", aTextField.text, NSStringFromRange(range), novoDigito);

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
        
        //NSLog (@"(<) executarBackspaceNoCampo:");
    }
}

+ (void)inserirDigitoNoCampo:(UITextField *)aTextField 
                       range:(NSRange)range 
                  novoDigito:(NSString *)novoDigito
{
    //NSLog (@"(>) inserirDigitoNoCampo: %@, %@, %@", aTextField.text, NSStringFromRange(range), novoDigito);

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
       
            //NSLog (@"(!) inserirDigitoNoCampo: aTextField.text = '%@'", aTextField.text);
        }
        
    }
    //NSLog (@"(<) inserirDigitoNoCampo: ");
}


+ (void)formataValor:(UITextField*)aTextField 
          novoDigito:(NSString*)novoDigito 
            comRange:(NSRange)range 
     usandoFormatter:(NSNumberFormatter *)formatter
      eQtdeDeDigitos:(int)qtdeDigitos
{
    //NSLog (@"(>) formataValor: %@, %@, %@, %@", aTextField.text, novoDigito, NSStringFromRange(range), formatter);

    [self executarBackspaceNoCampo:aTextField range:range novoDigito:novoDigito];
    [self inserirDigitoNoCampo:aTextField range:range novoDigito:novoDigito];

    // regex para aceitar apenas numeros
    NSString *regex = @"[0-9]*";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    NSString *buffer;
    buffer = [self removeCharsNaoNumericos:aTextField.text];
    
    // OK, agora verificamos se o valor adicionado é um numero, adicionamos ao final
    // do buffer para que ele seja formatado corretamente depois.
    
    //NSLog (@"(!) formataValor: buffer = %@", buffer);
        
    // Campo cheio, consome o novo digito
    if ([buffer length] == qtdeDigitos) { // Se o campo já tem o tamanho da mascara o caracter é ignorado.
        //NSLog (@"(!) formataValor: qtdeDigitos = %d", qtdeDigitos);
    } else if (![regextest evaluateWithObject:novoDigito]) {
        //NSLog (@"(!) formataValor: digito invalido = '%@'", novoDigito);
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
        
        //NSLog (@"(!) formataValor: aTextField.text = '%@'", aTextField.text);
  
    }
    //NSLog (@"(<) formataValor: ");

}

// retorna o mês atual no formato necessário para comparar
// com as parcelas.
+ (NSString *) formataMesParaTopCell:(NSDate *)data
{
    //NSLog (@"(>) retornaMesAtualFormatado: %@", data);

    NSString *retorno = nil;
    
    NSDateFormatter *dateFormatter;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM"];
    NSString *mes = [dateFormatter stringFromDate:data];
    mes = [mes stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[mes substringToIndex:1] uppercaseString]];
    [dateFormatter setDateFormat:@"yyyy"];
    retorno = [NSString stringWithFormat:@"Previsão para %@ de %@", mes, [dateFormatter stringFromDate:data]];
    
    //NSLog (@"(<) retornaMesAtualFormatado: return = %@", retorno);

    return retorno;
}

// retorna a data formatada apenas para o mês
+ (NSString *) formataApenasMesCompleto:(NSDate *)data
{
    //NSLog (@"(>) formataApenasMesCompleto: %@", data);
        
    NSDateFormatter *dateFormatter;
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM"];
    NSString *mes = [dateFormatter stringFromDate:data];
    mes = [mes stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[mes substringToIndex:1] uppercaseString]];
    
    //NSLog (@"(<) formataApenasMesCompleto: return = %@", mes);
    
    return mes;
}

//This method is responsible for add mask characters properly
+ (void)formatInput:(UITextField*)aTextField 
           string:(NSString*)aString 
           range:(NSRange)aRange 
           withMask:(NSString *)mask
{
    //NSLog (@"(>) formatInput: %@, %@, %@, %@", aTextField.text, aString, NSStringFromRange(aRange), mask);

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
                
                //NSLog (@"(!) formatInput: aTextField.text = '%@'", aTextField.text);
            }
        }
    }
    
    //NSLog (@"(<) formatInput: ");

}

// Retorna o primeiro dia do mês da data passada como parametro
+ (NSDate *) retornaPrimeiroDiaDoMes:(NSDate *)data
{
    //NSLog (@"(>) retornaPrimeiroDiaDoMes: %@", data);

    NSDate *retorno = nil;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:data];
    [comp setDay:1];
    retorno = [gregorian dateFromComponents:comp];

    //NSLog (@"(<) retornaPrimeiroDiaDoMes: return = %@", retorno);

    return retorno;
}

// Retorna o ultimo dia do mês
+ (NSDate *) retornaUltimoDiaDoMes:(NSDate *)data
{
    //NSLog (@"(>) retornaUltimoDiaDoMes: %@", data);
    
    NSDate *retorno = nil;
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSRange daysRange = [currentCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:data];
    //NSLog(@"(<) retornaUltimoDiaDoMes: dia = %i", daysRange.length);

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:data];
    [comp setDay:daysRange.length];
    retorno = [gregorian dateFromComponents:comp];
    
    //NSLog (@"(<) retornaUltimoDiaDoMes: return = %@", retorno);
    
    return retorno;    
}


+ (NSDecimalNumber *) retornaLimiteDeGastoGlobal
{
    //NSLog (@"(>) retornaLimiteDeGastoGlobal: ");

    NSDecimalNumber *valorFinal = nil;
    
    NSString *currentStringVal = [VidaParceladaHelper retornaLimiteDeGastoGlobalStr];
 
    NSNumberFormatter *valorFormatter;
    valorFormatter = [[NSNumberFormatter alloc] init];
    [valorFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    NSNumber *valor;
    valor = [valorFormatter numberFromString:currentStringVal];
    valorFinal = [NSDecimalNumber decimalNumberWithString:[valor stringValue]];

    //NSLog (@"(<) retornaLimiteDeGastoGlobal: return = %@", valorFinal);

    return valorFinal;
}


+ (NSString *) retornaLimiteDeGastoGlobalStr
{
    //NSLog (@"(>) retornaLimiteDeGastoGlobalStr: ");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *currentStringVal = [defaults objectForKey:@"objetivo"];
   
    //NSLog (@"(<) retornaLimiteDeGastoGlobalStr: return = %@", currentStringVal);

    return currentStringVal;
}


+ (void) salvaLimiteDeGastoGlobalStr:(NSString *)total
{
    //NSLog (@"(>) salvaLimiteDeGastoGlobalStr: %@", total);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:total forKey:@"objetivo"];
    [defaults synchronize];
    
    //NSLog (@"(<) salvaLimiteDeGastoGlobalStr: ");
}

+ (void) salvaNumeroDeParcelasPadrao:(NSNumber *)numParcelas
{
    //NSLog (@"(>) salvaNumeroDeParcelasPadrao: %@", numParcelas);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:numParcelas forKey:@"numParcelas"];
    [defaults synchronize];

    //NSLog (@"(<) salvaNumeroDeParcelasPadrao: ");
}

+ (NSNumber *) retornaNumeroDeParcelasPadrao
{
    //NSLog (@"(>) retornaNumeroDeParcelasPadrao: ");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *numParcelas = [defaults objectForKey:@"numParcelas"];

    if (!numParcelas) {
        //NSLog (@"(!) retornaNumeroDeParcelasPadrao: vazio, inicializando com 1.");
        numParcelas = [[NSNumber alloc] initWithInt:1];
        [VidaParceladaHelper salvaNumeroDeParcelasPadrao:numParcelas];
    }
    
    //NSLog (@"(<) retornaNumeroDeParcelasPadrao: return = %@", numParcelas);

    return numParcelas;
}

// Salva o estado da exibição da mensagem de boas vindas da de cada
// aba para o usuário utilizando NSDefaults
+ (void) salvaEstadoApresentacaoInicialAba:(NSString *)nomeAba exibido:(BOOL)estado
{
    //NSLog (@"(>) salvaEstadoApresentacaoInicialAba: %@, %@", nomeAba, (estado ? @"YES" : @"NO"));
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (estado) {
        [defaults setObject:@"YES" forKey:nomeAba];
    } else {
        [defaults setObject:@"NO" forKey:nomeAba];
    }
    
    // guarda abas criadas em um dictionary
    NSArray *arrayAbasOriginal = [defaults objectForKey:@"arrayAbas"];
    NSMutableArray *arrayAbas = [arrayAbasOriginal mutableCopy];
    if (!arrayAbas) {
        arrayAbas = [[NSMutableArray alloc] init];
        //NSLog (@"(!) salvaEstadoApresentacaoInicialAba: created = arrayAbas.");   
    }
    if (![arrayAbas containsObject:nomeAba]) {
        [arrayAbas addObject:nomeAba];
        //NSLog (@"(!) salvaEstadoApresentacaoInicialAba: added = arrayAbas(%@)", nomeAba);;   
    }
    [defaults setObject:arrayAbas forKey:@"arrayAbas"];

    [defaults synchronize];
    
    //NSLog (@"(<) salvaEstadoApresentacaoInicialAba: ");

}

// Retorna se a aba passada como parametro já foi exibida
+ (BOOL) retornaEstadoApresentacaoInicialAba:(NSString *)nomeAba
{
    BOOL resultado = NO;
    //NSLog (@"(>) retornaEstadoApresentacaoInicialAba: %@", nomeAba);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *estado = [defaults objectForKey:nomeAba];
    if (!estado) {
        [VidaParceladaHelper salvaEstadoApresentacaoInicialAba:nomeAba exibido:resultado];
        //NSLog (@"(!) retornaEstadoApresentacaoInicialAba: vazio, inicializando com NO.");   
    } else {
        resultado = [estado isEqual:@"YES"];
    }
    
    //NSLog (@"(<) retornaEstadoApresentacaoInicialAba: return = %@", (resultado ? @"YES" : @"NO"));
    
    return resultado;
}

// Volta ao estado inicial onde nenum aba foi apresentada.
+ (void) resetaTodosOsEstadosApresentacaoInicialAba
{
    //NSLog (@"(>) resetaTodosOsEstadosApresentacaoInicialAba: ");

    // guarda abas criadas em um dictionary
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayAbas = [defaults objectForKey:@"arrayAbas"];
    if (!arrayAbas) {
        arrayAbas = [[NSMutableArray alloc] init];
    } else {
        for (NSString *nomeAba in arrayAbas) {
            [defaults removeObjectForKey:nomeAba];
            //NSLog (@"(!) resetaTodosOsEstadosApresentacaoInicialAba: removed = %@", nomeAba);
        }
        [defaults removeObjectForKey:@"arrayAbas"];
    }
    [defaults synchronize];

    //NSLog (@"(<) resetaTodosOsEstadosApresentacaoInicialAba: ");
}


+ (void) trataErro:(NSError *)error
{
    if (error) {
        // Loga informações do erro
        NSLog (@"(!) <<<<< Erro encontrado - NSError code: %d >>>>>", error.code);
        NSLog (@"(!) <<<<< Description .......: %@ >>>>>", error.description);
        // tratamento específico para cada tipo de erro

    }
}

@end