Nonterminals list elements element.
Terminals '(' ')' ',' instruction int atom op rref dref src reaktor.
Rootsymbol list.

list -> '('')' : [].
list -> '(' list ')'.
list -> '(' elements ')' : '$2'.

elements -> element : ['$1']. 
elements -> element ',' elements : ['$1'|'$3'].

element -> instruction : extract_token('$1').
element -> int  : extract_token('$1').
element -> atom : extract_token('$1').
element -> op : extract_token('$1').
element -> rref : '$1'.
element -> dref : '$1'.
element -> src : '$1'.
element -> reaktor : '$1'.
element -> list : '$1'.

Erlang code.

extract_token({_Token, _Line, Value}) -> Value.