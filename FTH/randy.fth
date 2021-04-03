\ /* 16-bit xorshift PRNG */

\ unsigned xs = 1;

\ unsigned xorshift( )
\ {
\     xs ^= xs << 7;
\     xs ^= xs >> 9;
\     xs ^= xs << 8;
\     return xs;
\ }

1 VARIABLE SEED

: RND ( -- rnd )
    SEED @
    DUP 7 << XOR
    DUP 9 >> XOR
    DUP 8 << XOR
    DUP SEED !
;

: RNDS  0 DO RND U. LOOP ;
