# Things to beware of and before using DC
1. In vivado, clear every warning before sending your design to TSRI.
2. To see if there are any warnings left, look for design folder -> sim -> elaborate file and xvlog file, it would indicate the design faults.

# To use the EDAcloud
1. Log into TSRI with your account
2. Request a password for EDA cLOUD
3. Use NX to connect to server
4. Pack your design using FireZilla then push them onto EDAcloud using command, follow the instructions in manual.
5. You had better pack the whole design within a small folder.
6. If possible, use tcl for faster compilation.
7. After connecting to NX server edaCloud, from command pallete insert the user name and password to access and send the file from FireZilla.
8. Use unzip command to unpack zip file you just sent.