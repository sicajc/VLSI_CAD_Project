# NCHU VLSI CAD Final project

## Index

## Introduction
1. A 16-bit 5-stage pipelined RISC Processor with floating point coprocessor is implemented, using a small set of Custom RISC ISA. In order to enhance performace, forwarding unit and hazard detection unit are also implemented to resolve the data hazard and control hazard.

2.  The coprocessor is implemented using simplfied 16-bit IEEE format as an additional module.

![Block Diagram](image/16-bit%20RISC%20Pipelined%20Processor%20with%20FP%20unit.png)

## 5-stage RISC pipelined Processor

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
    PS_DP --> ALU
    PS_DP --> IM(Instruction Memory)
    PS_DP --> DM(Data Memory)
    PS_DP --> PC(Program Counter)
    PS_DP --> PR(Pipelined Registers)

    SPS_CTR --> FW[Forwarding Unit]
    SPS_CTR --> HD[Hazard_Detection]
    SPS_CTR --> ST[Stall control]


    PS_CTR --> OP[OPcode]

```
# Datapath
1. Main Datapath
![Datapath](image/datapath_pipeline.png)

# Controlpath
## CTR
![ControlPath](image/OP_CTR_code.png)

## Hazard Unit

![HazardUnit](image/HazardUnits.png)

# Forwarding Condition
>To solve Data hazard including R-R sw-lw

ALU_src1:
```verilog
    if((rsE!=0)and(rsE == WriteRegM) and (RegWriteM))
        ALU_src1 = 01
    else if ((rsE!=0) and (rsE == WriteRegW) and RegWriteW)
        ALU_src1 = 10
    else
        ALU_src1 = 00
```

ALU_src2:
```verilog
    if((rsE!=0)and(rsE == WriteRegM) and (RegWriteM == 1))
        ALU_src2 = 01
    else if ((rsE!=0) and (rsE == WriteRegW) and RegWriteW == 1)
        ALU_src2 = 10
    else
        ALU_src2 = 0
```

MemSrc:
> To solve sw-lw data hazard
```verilog
    if((rsM!=0) and (rsM == WriteRegW) and (MemRead == 1))
        MemSrc = 1
    else
        MemSrc = 0
```


## Stall Condition
> To solve lw-r data hazard and stop signal

```verilog
    if(stop)
        stall Every Pipeline and PC
    else if( ((rsI == rsE) and (rsI!=0)) or ((rsI == rsE) and (rtI != 0 )) and (MemRead == 1))
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



# Testbench
# References
