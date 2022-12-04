 
****************************************
Report : resources
Design : pipelinedPS
Version: N-2017.09-SP2
Date   : Mon Nov 28 20:45:39 2022
****************************************


Resource Report for this hierarchy in file
        /home/rain/VLSI_CAD_Project/16_bit_Pipelined_processor/pipelinedPS.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| gte_x_1        | DW_cmp         | width=8    | gte_97 (pipelinedPS.v:97)  |
| eq_x_3         | DW_cmp         | width=4    | u_hazardUnit/eq_60 (hazardUnit.v:60) |
| eq_x_4         | DW_cmp         | width=4    | u_hazardUnit/eq_64 (hazardUnit.v:64) |
| eq_x_6         | DW_cmp         | width=4    | u_hazardUnit/eq_77 (hazardUnit.v:77) |
| eq_x_7         | DW_cmp         | width=4    | u_hazardUnit/eq_81 (hazardUnit.v:81) |
| eq_x_9         | DW_cmp         | width=4    | u_hazardUnit/eq_93 (hazardUnit.v:93) |
| eq_x_10        | DW_cmp         | width=4    | u_hazardUnit/eq_116 (hazardUnit.v:116) |
| eq_x_11        | DW_cmp         | width=4    | u_hazardUnit/eq_116_2 (hazardUnit.v:116) |
| add_x_17       | DW01_inc       | width=3    | u_hazardUnit/add_171 (hazardUnit.v:171) |
| add_x_23       | DW01_inc       | width=8    | u_IF/add_76 (IF.v:76)      |
| lt_x_45        | DW_cmp         | width=16   | u_EX/lt_121 (EX.v:121)     |
| DP_OP_106J1_122_570             |            |                            |
|                | DP_OP_106J1_122_570 |       |                            |
=============================================================================

Datapath Report for DP_OP_106J1_122_570
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_106J1_122_570  | u_EX/add_119 (EX.v:119) u_EX/sub_120 (EX.v:120)     |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Signed   | 16    |                                          |
| I2    | PI   | Signed   | 16    |                                          |
| I3    | PI   | Unsigned | 1     |                                          |
| O1    | PO   | Signed   | 16    | addsub(I1,I2,I3) ( EX.v:119 EX.v:120 )   |
==============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| gte_x_1            | DW_cmp           | apparch (area)     |                |
| eq_x_3             | DW_cmp           | apparch (area)     |                |
| eq_x_4             | DW_cmp           | apparch (area)     |                |
| eq_x_6             | DW_cmp           | apparch (area)     |                |
| eq_x_7             | DW_cmp           | apparch (area)     |                |
| eq_x_9             | DW_cmp           | apparch (area)     |                |
| eq_x_10            | DW_cmp           | apparch (area)     |                |
| eq_x_11            | DW_cmp           | apparch (area)     |                |
| add_x_17           | DW01_inc         | apparch (area)     |                |
| add_x_23           | DW01_inc         | apparch (area)     |                |
| lt_x_45            | DW_cmp           | apparch (area)     |                |
| DP_OP_106J1_122_570                   |                    |                |
|                    | DP_OP_106J1_122_570 | str (area)      |                |
===============================================================================

1
