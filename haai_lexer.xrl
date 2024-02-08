Definitions.

INT = [0-9]+
INSTRUCTION = I[A-Z-]+
OP = [+\-*\/]
ATOM = [a-z-]+
WHITESPACE = [\s\t\n\r]
RREF = \%RREF
DREF = \%DREF
SRC = \%SRC
REAKTOR = \%R

Rules.

{INT}         : {token, {int, TokenLine, list_to_integer(TokenChars)}}.
{INSTRUCTION} : {token, {instruction, TokenLine, TokenChars}}.
{RREF}        : {token, {rref, TokenLine}}.
{DREF}        : {token, {dref, TokenLine}}.
{SRC}         : {token, {src, TokenLine}}.
\(            : {token, {'(', TokenLine}}.
\)            : {token, {')', TokenLine}}.
{OP}          : {token, {op, TokenLine, TokenChars}}.
{REAKTOR}     : {token, {reaktor, TokenLine}}.
{ATOM}        : {token, {atom, TokenLine, TokenChars}}.
{WHITESPACE}+ : skip_token.

Erlang code.

