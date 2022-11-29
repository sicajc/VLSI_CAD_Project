 
****************************************
Report : resources
Design : pipelinedPS
Version: N-2017.09-SP2
Date   : Tue Nov 29 22:25:03 2022
****************************************


Resource Report for this hierarchy in file
        /home/rain/VLSI_CAD_Project/16_bit_Pipelined_processor/pipelinedPS.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| eq_x_4         | DW_cmp         | width=4    | u_hazardUnit/eq_59 (hazardUnit.v:59) |
| eq_x_5         | DW_cmp         | width=4    | u_hazardUnit/eq_63 (hazardUnit.v:63) |
| eq_x_7         | DW_cmp         | width=4    | u_hazardUnit/eq_76 (hazardUnit.v:76) |
| eq_x_8         | DW_cmp         | width=4    | u_hazardUnit/eq_80 (hazardUnit.v:80) |
| eq_x_10        | DW_cmp         | width=4    | u_hazardUnit/eq_92 (hazardUnit.v:92) |
| eq_x_11        | DW_cmp         | width=4    | u_hazardUnit/eq_105 (hazardUnit.v:105) |
| eq_x_12        | DW_cmp         | width=4    | u_hazardUnit/eq_105_2 (hazardUnit.v:105) |
| add_x_15       | DW01_inc       | width=3    | u_hazardUnit/add_160 (hazardUnit.v:160) |
| add_x_20       | DW01_inc       | width=8    | u_IF/add_73 (IF.v:73)      |
| lt_x_41        | DW_cmp         | width=16   | u_EX/lt_121 (EX.v:121)     |
| DP_OP_102_125_5397              |            |                            |
|                | DP_OP_102_125_5397 |        |                            |
=============================================================================

Datapath Report for DP_OP_102_125_5397
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_102_125_5397   | u_EX/add_119 (EX.v:119) u_EX/sub_120 (EX.v:120)     |
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
| eq_x_4             | DW_cmp           | apparch (area)     |                |
| eq_x_5             | DW_cmp           | apparch (area)     |                |
| eq_x_7             | DW_cmp           | apparch (area)     |                |
| eq_x_8             | DW_cmp           | apparch (area)     |                |
| eq_x_10            | DW_cmp           | apparch (area)     |                |
| eq_x_11            | DW_cmp           | apparch (area)     |                |
| eq_x_12            | DW_cmp           | apparch (area)     |                |
| add_x_15           | DW01_inc         | apparch (area)     |                |
| add_x_20           | DW01_inc         | apparch (area)     |                |
| lt_x_41            | DW_cmp           | apparch (area)     |                |
| DP_OP_102_125_5397 | DP_OP_102_125_5397 | str (area,speed) |                |
===============================================================================

1
