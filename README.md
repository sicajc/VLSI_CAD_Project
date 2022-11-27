# NCHU VLSI CAD Final project

## Index
1. [Introduction](#introduction)
2. [Datapath](#datapath)
3. [Controlpath](#controlpath)
4. [TestBench](#testbench)


## Introduction
1. A 16-bit 5-stage pipelined RISC Processor with floating point coprocessor is implemented, using a small set of Custom RISC ISA. In order to enhance performace, forwarding unit and hazard detection unit are also implemented to resolve the data hazard and control hazard.

2.  The coprocessor is implemented using simplfied 16-bit IEEE format as an additional module.

3. To start the processor, raise the input start signal to 1, the flag would get stored inside the state Register(SR) to ensure the processor keeps on running.

4. The stop signal is a part of instruction, it would get decoded at ID stage. After stopping the processor, everything would get stalled.

![Block Diagram](image/16-bit%20RISC%20Pipelined%20Processor%20with%20FP%20unit.png)

## 5-stage RISC pipelined Processor
### ISA
![ISA](image/ISA_Instruction_Description.png)

### System tree diagram
```mermaid

   graph TD
    PS(Pipelined Processor);
    ALU --> FP(Floating point coprocessor)

    FP --> FP_CTR[Control]
    FP --> E[Datapath]

    PS --> PS_CTR[Control]
    PS --> SPS_CTR[Sub-Control]
    PS --> PS_DP[Datapath]

    PS_DP --> REG[Register file]
    PS_DP --> ALU[IF]
    PS_DP --> IM(Instruction Memory)
    PS_DP --> DM(Data Memory)
    PS_DP --> PC(Program Counter)
    PS_DP --> PR(Pipelined Registers)

    SPS_CTR --> FW[Forwarding Unit]
    SPS_CTR --> HD[Hazard_Detection]
    SPS_CTR --> ST[Stall control]


    PS_CTR --> OP[OPcode]

```



### Processor block diagram
<br />![Processor](image/Processor.png)

# Datapath
1. Main Datapath
![Datapath](image/datapath_pipeline.png)

# Controlpath
## CTR Signal and corresponding Control vector
![ControlPath](image/OP_CTR_code.png)

## Hazard Unit

![HazardUnit](image/HazardUnits.png)

# Forwarding Condition
>To solve Data hazard including R-R sw-lw

ALU_src1:
```verilog
    if((rsE!=0)and(rsE == WriteRegM) and (RegWriteM))
        ALU_src1 = 01
    else if ((rsE!=0) and (rsE == WriteRegW) and (RegWriteW ==1 ))
        ALU_src1 = 10
    else
        ALU_src1 = 00
```

ALU_src2:
```verilog
    if((rtE!=0)and(rtE == WriteRegM) and (RegWriteM == 1))
        ALU_src2 = 01
    else if ((rtE!=0) and (rtE == WriteRegW) and (RegWriteW == 1))
        ALU_src2 = 10
    else
        ALU_src2 = 00
```

MemSrc:
> To solve sw-lw data hazard
```verilog
    if((rsM!=0) and (rsM == WriteRegW) and (MemReadW == 1) and (MemWriteM == 1))
        MemSrc = 1
    else
        MemSrc = 0
```


## Stall Condition
> To solve lw-r data hazard and stop signal

```verilog
    if(stop)
        stall Every Pipeline and PC
    else if( ((rsD==rsE) or (rtD == rsE)) and (MemReadE == 1) and (ID Stage is NOT I type))
        stall PC and flush ID/EX
    else
        do nothing
```

## Control Hazard Control
> To solve j and branch hazard

```verilog
    if(jump == 1)
        flush IF/ID
    else if (PCSrc == 1)
        flush EX/MEM for 3 cycles
    else
        do nothing
```

### Debug notes
1. stop register is added , the reason is that stop signal can only be decoded in ID stage, however the stop signal needs to be read during IF stage for PC, otherwise it cannot know which state it is in.

2. Processor Status Register(SR) is added s.t. we can know whether processor is running or not, if it is not running, PC would be locked.

3. Any kind of control signal had better be kept using a status register to prevent some error, otherwise unexpected erros might occur due to unknown value given.

4. You forget to redesign the RF file s.t. it can write at negedge and read at positive edge.

5. When executing Instructions, you should give enough nop before stop for previous instructions to actually complete.

6. When specifying components, you MUST first UNIT Test every Components before putting them into actions. Just give them some simple testbench s.t. you are sure that they are working as expected. THIS WOULD SAVE YOU TONS OF TIME!!!!!!!! I didnt notice that RF is not blocked.

7. Remember to check whether you have used the right testbenches or whether you have correct the testbenches into the right one.
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
                        //dm[12] = 7
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
Testing R-lw hazard
```
    lw $2,0
    lw $3,1
    lw $4,2
    nop
    nop
    add $5,$2,$3
    lw  $1,$3
    add $6,$1,$2
    add $7,$1,$2
    stop
    nop
```
## Test4
Testing sw-lw forwarding
```
    lw $2,0
    lw $3,1
    lw $4,2
    add $5,$3,$4
    lw $1,3
    sw $1,6
    nop
    nop
    stop
    nop
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

# Synthesis Result


# APR


# References
