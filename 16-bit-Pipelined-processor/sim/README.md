# Testbench

## Test1

```C

int a = 3;
int b = 4;
int c = 0;
int addr = &12;
c = a + b;
dm[addr] = c;

```

Testing basic instructions without forwarding and stalling.

```python

mov $1,3
mov $2,4
mov $3,0
mov $4,12
nop
nop
add $3,$2,$1
nop
nop
sw  $3,12
stop
nop infinity.

```

Machine Code:

```verilog
0:  0011_0001_0000_0011 //mov $1,3
1:  0011_0010_0000_0100 //mov $2,4
2:  0011_0011_0000_0000 //mov $3,0
3:  0011_0100_0000_1100 //mov $4,12
6:  1111_0000_0000_0000 // nop
7:  1111_0000_0000_0000 // nop
4:  0010_0010_0001_0011 //add $3,$2,$1
5:  1111_0000_0000_0000 // nop
6:  1111_0000_0000_0000 // nop
7:  0001_0011_0000_1100 //sw $3,12
8:  1111_0000_0000_0000 // nop
9:  1111_0000_0000_0000 // nop
10: 1111_0000_0000_0000 // nop
11: 1111_0000_0000_0000 // nop
12: 1111_0000_0000_0000 // nop
13: 0111_0000_0000_0000 // stop

                        /dm[12] = 7

```

## Test2

Testing R-R forwarding and the functionality of lw.

```C
//D[0] = 10;
//D[1] = 20;
//D[2] = 30;
int a = D[0];
int b = D[1];
int c = D[2];
d = a - b; //d = -10
c = a + b; //c = 30
a = c + a; //a = 40
a = a + a; //a = 80
c = a + a; //c = 160
D[3] = c; //D[3] = 160
D[4] = d; //D[4] = -10

```

Assembly:

```python
lw $1 , 0 //int a = D[0];
lw $2 , 1 //int b = D[1];
lw $3 , 2 //int c = D[2];
nop // To prevent lw-r hazard first
nop
sub $4,$1,$2 // d = a - b
add $3,$1,$2 // c = a + b
add $1,$3,$1 // a = c + a , forwarding $3
add $1,$1,$1 // a = a + a , forwarding $1
add $3,$1,$1 // c = a + a , forwarding $1
sw  $3 , 3   // D[3]      , forwarding $3
sw  $4 , 4   // D[4]
nop
nop
nop
nop
stop
//Check D[3] = 160 and D[4] = -10

```

Machine Code:

```verilog
//a = $1, b = $2 , c = $3 , d = $4
0:      0000_0001_0000_0000 //lw $1,0
1:      0000_0010_0000_0001 //lw $2,1
2:      0000_0011_0000_0010 //lw $3,2
3:      1111_0000_0000_0000 // nop
4:      1111_0000_0000_0000 // nop
5:      0100_0001_0010_0100 //sub $4,$1,$2
6:      0010_0001_0010_0011 //add $3,$1,$2
7:      0010_0011_0001_0001 //add $1,$3,$1
8:      0010_0001_0001_0001 //add $1,$1,$1
9:      0010_0001_0001_0011 //add $3,$1,$1
10:     0001_0011_0000_0011 // sw $3,3
11:     0001_0100_0000_0100 // sw $4,4
12:     1111_0000_0000_0000 // nop
13:     1111_0000_0000_0000 // nop
14:     1111_0000_0000_0000 // nop
15:     1111_0000_0000_0000 // nop
16:     0111_0000_0000_0000 // stop
17:     1111_0000_0000_0000 // nop
18:     1111_0000_0000_0000 // nop
.               .           // nop

.               .           // nop

.               .           // nop

                            //D[3] = 160

                            //D[4] = -10

```
## Test3
1. Debug notes

Problem occurs at PC, it reads out the wrong instruction after stalling.(Solved if seting IM to negative edge triggered) WHY?

Q: What should be negative triggered? What should be positive edge triggered?
Testing R-lw hazard
```C
//D[0] = 10, D[1] = 20 , D[2] = 30
int a = D[0];
int b = D[1];
int c = D[2];
d = b + c;
d = d + d;
a = b + c;
D[0] = a;
D[1] = d;
//Result D[0] = 50
//Result D[1] = 80
```
Assembly
```python
# a = $0 , b = $1 , c = $2
lw $0,0
lw $1,1
lw $2,2
add $3,$1,$2 #(lw-r hazard) at $2
add $3,$3,$3
add $0,$1,$2
sw $0,0
sw $3,1
nop
nop
nop
stop
nop
nop
nop
```
Machine Code
```python
0 :0000_0000_0000_0000
1 :0000_0001_0000_0001
2 :0000_0010_0000_0010
3 :0010_0001_0010_0011
4 :0010_0011_0011_0011
5 :0010_0001_0010_0000
6 :0001_0000_0000_0000
7 :0001_0011_0000_0001
8 :1111_0000_0000_0000
9 :1111_0000_0000_0000
10:1111_0000_0000_0000
11:0111_0000_0000_0000
12:1111_0000_0000_0000
13:1111_0000_0000_0000
14:1111_0000_0000_0000
15:1111_0000_0000_0000
16:     .

    .

    .

    .
//Result D[0] = 50
//Result D[1] = 80
```
## Test4
Testing sw-lw forwarding
```C
//D[0] = 10;
int a = 3;
int b = 4;
int c = 0;
c = D[0];
D[1] = c;
```
Assembly
```python
#D[0] = 10, a = $0 ,
mov $0 , 3
mov $1 , 4
mov $2 , 0
lw  $2 , 0
sw  $2 , 1
nop
nop
nop
nop
stop
nop
nop
nop
```
Machine Code
```
0:  0011_0000_0000_0011
1:  0011_0001_0000_0100
2:  0011_0010_0000_0000
3:  0000_0010_0000_0000
4:  0001_0010_0000_0001
5:  1111_0000_0000_0000
6:  1111_0000_0000_0000
7:  1111_0000_0000_0000
8:  1111_0000_0000_0000
9:  0111_0000_0000_0000
10: 1111_0000_0000_0000
11: 1111_0000_0000_0000
12: 1111_0000_0000_0000
```
## Test5
Branch control
```
loop:

    j loop
exit:
```
## Full testing
```
loop: add $3,$4,$5

add $5,$3,$2

add $2,$5,$3

lw $2,4

add $3,$2,$4

mov $4,7

add $5,$4,$3

sw  $5,3

lw  $7,4

sw  $7,2

add $3,$3,$5

jmpz $3, loop

add $4,$5,$6

lw  $4,7

sw  $7,2

stop
```