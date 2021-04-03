
: SCALE   >R -1 0 R> U/ SWAP DROP ;

: RAN   SCALE >R RND 0 R> U/ SWAP DROP ;

: D0    RAN 1+ ;

: D             \ n mag
  SWAP          \ mag n
  0 SWAP        \ mag sum n
  0             \ mag sum n 0
  DO            \ mag sum
    OVER        \ mag sum mag
    D0          \ mag sum r
    +           \ mag sum
  LOOP
  SWAP DROP     \ sum
;

0 VARIABLE CNT 30 ALLOT

: DT    0 DO 2 6 D 1 << CNT + 1 SWAP +! LOOP ;

: CLR   CNT 30 ERASE ;

: PRETTY
  CR
  13 2
  DO
    I DUP 3 .R BL EMIT 1 << CNT + @ 10 / 0
    DO
      ASCII * EMIT
    LOOP
    CR
  LOOP
  CR
;

CLR

\ 2000 DT PRETTY
