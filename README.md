**Some Verilog demos for Basys 3 Artix 7 board**

Compile them independently of each other with Vivado and program into Basys3.

1-  vga-truerandom-basys3.v extracts randomness from race conditions of 2 ring oscillators and puts them on a VGA signal. If it works OK you should see random snow in a VGA monitor.

2-  leds-basys3.v is a basic example that counts in binary with the output leds. Useful for an introductory course of Verilog.
