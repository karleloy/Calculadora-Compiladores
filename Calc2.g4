grammar Calc2;

@members {
    // HashMap para armazenar as variáveis e seus valores
    Map<String, Double> memory = new HashMap<>();
    java.util.Scanner scanner = new java.util.Scanner(System.in);
}

// Regra inicial
prog:   stat+;

// Definição de uma instrução
stat
    :   ID ASSIGN expr SC {
            memory.put($ID.text, $expr.result);            
        }  # assignStat
    |   'input' AP ID FP SC {
            System.out.print("Entre com o valor de " + $ID.text + ": ");
            double value = scanner.nextDouble();
            memory.put($ID.text, value);            
        }  # inputStat
    |   'print' AP expr FP SC {
            if ($expr.isBoolean) {
                System.out.println("Resultado: " + ($expr.result == 1.0 ? "true" : "false"));
            } else {
                System.out.println("Resultado: " + $expr.text + " = " + $expr.result);
            }
        }  # printStat
    ;

// Expressões
expr returns [double result, boolean isBoolean]
    :   left=termo {
            $result = $left.result;
            $isBoolean = false;
        }
        (   op=(LT | GT | LE | GE | EQ | NE) right=termo {
                switch ($op.text) {
                    case "<":  $result = $left.result < $right.result ? 1.0 : 0.0; break;
                    case ">":  $result = $left.result > $right.result ? 1.0 : 0.0; break;
                    case "<=": $result = $left.result <= $right.result ? 1.0 : 0.0; break;
                    case ">=": $result = $left.result >= $right.result ? 1.0 : 0.0; break;
                    case "==": $result = $left.result.equals($right.result) ? 1.0 : 0.0; break;
                    case "!=": $result = !$left.result.equals($right.result) ? 1.0 : 0.0; break;
                }
                $isBoolean = true;
            }
        |   ADD right=termo {
                $result += $right.result;
            }
        |   SUB right=termo {
                $result -= $right.result;
            }
        )*;

// Termos
termo returns [double result]
    :   left=fator {
            $result = $left.result;
        }
        (   MUL right=fator {
                $result *= $right.result;
            }
        |   DIV right=fator {
                $result /= $right.result;
            }
        )*;

// Fatores
fator returns [double result]
    :   NUM {
            $result = Double.parseDouble($NUM.text);
        }  # numberFactor
    |   ID {
            $result = memory.getOrDefault($ID.text, 0.0);
        }  # idFactor
    |   AP e=expr FP {
            $result = $e.result;
        }  # parensFactor
    ;

// Tokens
ADD     : '+';
SUB     : '-';
MUL     : '*';
DIV     : '/';
ASSIGN  : '=';
LT      : '<';
GT      : '>';
LE      : '<=';
GE      : '>=';
EQ      : '==';
NE      : '!=';
AP      : '(';
FP      : ')';
SC      : ';';  
ID      : [a-zA-Z_][a-zA-Z_0-9]*;
NUM     : [0-9]+ ('.' [0-9]+)?;
WS      : (' ' | '\t' | '\n' | '\r') -> skip;
