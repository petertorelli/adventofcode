## Part 1

Zero delay circuit simulator.

I literally wrote on of these at Intel in 1996.


## Part 2

Threw it into 

https://dreampuf.github.io/GraphvizOnline/#digraph%20G%20%7B%0Abutton%20-%3E%20broadcaster%3B%0Asf%20-%3E%20pz%2C%20gj%3B%0Azh%20-%3E%20bc%2C%20st%3B%0Ahk%20-%3E%20bc%3B%0Abc%20-%3E%20mn%2C%20zl%2C%20xb%2C%20mm%2C%20dh%2C%20hv%2C%20gz%3B%0Ast%20-%3E%20bc%2C%20mm%3B%0Agv%20-%3E%20xf%2C%20qq%3B%0Ahv%20-%3E%20xb%3B%0And%20-%3E%20gj%2C%20tr%3B%0Azx%20-%3E%20bx%2C%20ms%3B%0Asc%20-%3E%20ks%2C%20gj%3B%0Agr%20-%3E%20hn%3B%0Apl%20-%3E%20qq%2C%20rh%3B%0Aqc%20-%3E%20sf%2C%20gj%3B%0Axr%20-%3E%20sc%2C%20gj%3B%0Azl%20-%3E%20zh%3B%0Agj%20-%3E%20ks%2C%20ld%2C%20sg%2C%20xr%3B%0Adg%20-%3E%20ll%2C%20bx%3B%0Anf%20-%3E%20bc%2C%20tg%3B%0Alz%20-%3E%20cv%2C%20qq%3B%0Anq%20-%3E%20dg%2C%20bx%3B%0Arh%20-%3E%20qq%2C%20lp%3B%0Axf%20-%3E%20qq%2C%20qj%3B%0Ams%20-%3E%20bx%2C%20xh%3B%0Amn%20-%3E%20bc%2C%20hv%3B%0Ajm%20-%3E%20rx%3B%0Axh%20-%3E%20vt%2C%20bx%3B%0Apz%20-%3E%20gj%3B%0Avq%20-%3E%20bt%3B%0Agz%20-%3E%20nf%3B%0Abt%20-%3E%20gr%3B%0Asg%20-%3E%20jm%3B%0Afr%20-%3E%20bx%2C%20tb%3B%0Alm%20-%3E%20jm%3B%0Ald%20-%3E%20cl%3B%0Acv%20-%3E%20vq%3B%0Acl%20-%3E%20gj%2C%20jf%3B%0Atr%20-%3E%20gj%2C%20sz%3B%0Asz%20-%3E%20gj%2C%20ld%3B%0Adx%20-%3E%20hk%2C%20bc%3B%0Alr%20-%3E%20bx%2C%20fr%3B%0Avt%20-%3E%20lr%2C%20bx%3B%0All%20-%3E%20zx%3B%0Abroadcaster%20-%3E%20pl%2C%20xr%2C%20mn%2C%20xc%3B%0Alp%20-%3E%20lz%3B%0Amm%20-%3E%20gz%3B%0Aqq%20-%3E%20lm%2C%20gr%2C%20cv%2C%20vq%2C%20lp%2C%20pl%2C%20bt%3B%0Axb%20-%3E%20zl%3B%0Abx%20-%3E%20ll%2C%20xc%2C%20db%3B%0Atb%20-%3E%20bx%3B%0Ahn%20-%3E%20gv%2C%20qq%3B%0Ajf%20-%3E%20qc%2C%20gj%3B%0Aqj%20-%3E%20qq%3B%0Axc%20-%3E%20bx%2C%20pm%3B%0Atg%20-%3E%20bc%2C%20dx%3B%0Adh%20-%3E%20jm%3B%0Aks%20-%3E%20nd%3B%0Adb%20-%3E%20jm%3B%0Apm%20-%3E%20bx%2C%20nq%3B%0A%7D

And you can see that node JM has to drive 0.

So looked at all the cycle counts for the inputs and noticed they all repeated
at some period Nx. Computed the period for N[sg, lm, dh, db], the computed
the product of N and got the answer.

```
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
lm ::       3851 0 -> 0 -> 1
lm ::       7702 0 -> 0 -> 1
lm ::      11553 0 -> 0 -> 1
lm ::      15404 0 -> 0 -> 1
lm ::      19255 0 -> 0 -> 1
lm ::      23106 0 -> 0 -> 1
lm ::      26957 0 -> 0 -> 1
lm ::      30808 0 -> 0 -> 1
lm ::      34659 0 -> 0 -> 1
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
dh ::       3889 0 -> 0 -> 1
dh ::       7778 0 -> 0 -> 1
dh ::      11667 0 -> 0 -> 1
dh ::      15556 0 -> 0 -> 1
dh ::      19445 0 -> 0 -> 1
dh ::      23334 0 -> 0 -> 1
dh ::      27223 0 -> 0 -> 1
dh ::      31112 0 -> 0 -> 1
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
db ::       4079 0 -> 0 -> 1
db ::       8158 0 -> 0 -> 1
db ::      12237 0 -> 0 -> 1
db ::      16316 0 -> 0 -> 1
db ::      20395 0 -> 0 -> 1
db ::      24474 0 -> 0 -> 1
db ::      28553 0 -> 0 -> 1
db ::      32632 0 -> 0 -> 1
petertorelli@Hipparchus day20 % ./main2.pl fract1.txt  | grep '1$'
sg ::       4027 0 -> 0 -> 1
sg ::       8054 0 -> 0 -> 1
sg ::      12081 0 -> 0 -> 1
sg ::      16108 0 -> 0 -> 1
sg ::      20135 0 -> 0 -> 1
sg ::      24162 0 -> 0 -> 1
sg ::      28189 0 -> 0 -> 1

3851 * 3889 * 4079 * 4027 = 246,006,621,493,687
```