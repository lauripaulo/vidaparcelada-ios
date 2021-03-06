//
//  VidaParceladaHelper.h
//  VidaParcelada
//
//  Created by Lauri Paulo Laux Junior on 21/04/12.
//  Copyright (c) 2012 Gettin'App. All rights reserved.
//

#import <Foundation/Foundation.h>

// Nesta classe estão impelementados os metodos comuns e "estáticos"
// que fazem coisas úteis na aplicação. Como formatar um número,
// formatar uma data, acompanhar o estado de digitação de um campo,
// etc.
@interface VidaParceladaHelper : NSObject


// formata campo com mascar fixa, bom para formatar telefones por exemplo
+ (void)formatInput:(UITextField*)aTextField 
             string:(NSString*)aString 
              range:(NSRange)aRange 
           withMask:(NSString *)mask;

// formata valores numericos da direita para a esquerda com separador decimal e de centenas
// fixo nas posições esperadas. QtdeDeDigitos é a quantidade de digitos numericos sem a 
// formatação, ex: 123.456,78 tem QtdeDeDigitos=8
+ (void)formataValor:(UITextField*)aTextField 
          novoDigito:(NSString*)novoDigito 
            comRange:(NSRange)range 
     usandoFormatter:(NSNumberFormatter *)formatter
      eQtdeDeDigitos:(int)qtdeDigitos;

// retorna o mês atual no formato necessário para comparar
// com as parcelas.
+ (NSString *) formataMesParaTopCell:(NSDate *)data;

// retorna a data formatada apenas para o mês
+ (NSString *) formataApenasMesCompleto:(NSDate *)data;

// Retorna o primeiro dia do mês da data passada como parametro
+ (NSDate *) retornaPrimeiroDiaDoMes:(NSDate *)data;

// Retorna o ultimo dia do mês
+ (NSDate *) retornaUltimoDiaDoMes:(NSDate *)data;

// Retorna o objetivo de gasto global do NSUserDefaults
// em formato de string (que é nativamente suportado)
// e retorna convertido para NSDecimalNumber para quem chamou a função.
+ (NSDecimalNumber *) retornaLimiteDeGastoGlobal;

// Retorna o objetivo de gasto global do NSUserDefaults
// em formato de string (que é nativamente suportado)
+ (NSString *) retornaLimiteDeGastoGlobalStr;

// Salva o limite de gasto global em formato de string
// no NSUserDefaults para uso posterior
+ (void) salvaLimiteDeGastoGlobalStr:(NSString *)total;

// Função que recebe um NSError e loga as informações se for pertinente
+ (void) trataErro:(NSError *)error;

// Salva o numero de parcelas padrão do usuário
+ (void) salvaNumeroDeParcelasPadrao:(NSNumber *)numParcelas;

// Retorna o numero de parcelas padrão do usuário
+ (NSNumber *) retornaNumeroDeParcelasPadrao;

// Salva o estado da exibição da mensagem de boas vindas da de cada
// aba para o usuário utilizando NSDefaults
+ (void) salvaEstadoApresentacaoInicialAba:(NSString *)nomeAba exibido:(BOOL)estado;

// Retorna se a aba passada como parametro já foi exibida
+ (BOOL) retornaEstadoApresentacaoInicialAba:(NSString *)nomeAba;

// Volta ao estado inicial onde nenum aba foi apresentada.
+ (void) resetaTodosOsEstadosApresentacaoInicialAba;

@end
