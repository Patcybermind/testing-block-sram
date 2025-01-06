//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9.03 Education (64-bit)
//Part Number: GW2AR-LV18QN88C8/I7
//Device: GW2AR-18
//Device Version: C
//Created Time: Sun Jan  5 22:05:47 2025

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

Gowin_SP your_instance_name(
    .dout(dout), //output [7:0] dout
    .clk(clk), //input clk
    .oce(oce), //input oce
    .ce(ce), //input ce
    .reset(reset), //input reset
    .wre(wre), //input wre
    .ad(ad), //input [3:0] ad
    .din(din) //input [7:0] din
);

//--------Copy end-------------------
