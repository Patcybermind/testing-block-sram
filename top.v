
module top
(
    input clk,
    output [5:0] led,
    input wire uart_rx,
    output wire uart_tx
);

localparam WAIT_TIME = 13500000; // .5 second
reg [5:0] ledCounter = 0;
reg [23:0] clockCounter = 0;

wire [7:0] dout;
reg [7:0] di;
reg [3:0] address;
reg wre;
reg [5:0] ledOutput;
reg [3:0] ramAdress = 0;

/*
Gowin_RAM16S your_instance_name(
        .dout(dout), //output [7:0] dout
        .di(di), //input [3:0] di
        .ad(address), //input [3:0] ad
        .wre(wre), //input wre
        .clk(clk) //input clk
);
*/


reg ce = 1;
reg oce = 1;
reg [3:0] ad;
reg bramWre;
reg bramReset; // NOT SURE WHAT IT SHOULD BE BY DEFAULT
reg [7:0] bramDin;
reg [3:0] bramAddress;

wire [7:0] bramDout;

Gowin_SP your_instance_name(
    .dout(bramDout), //output [7:0] dout
    .clk(clk), //input clk
    .oce(oce), //input oce which means 
    .ce(ce), //input ce clock enable
    .reset(bramReset), //input reset
    .wre(bramWre), //input wre 0 means read, 1 means write
    .ad(bramAddress), //input [3:0] ad
    .din(bramDin) //input [7:0] din
);

wire [7:0] receivedData;
reg [7:0] dataOut;
reg sendOnLow;

uart usb(
    .clk(clk),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    //.led(led), 
    .dataOut(dataOut),
    .receivedData(receivedData),
    .sendOnLow(sendOnLow)
);


/*always @(posedge clk) begin
    clockCounter <= clockCounter + 1'b1;
    if (clockCounter == WAIT_TIME) begin
        clockCounter <= 0;
        ramAdress <= ramAdress + 1;
        
        wre <= 0; // read
        ad <= ramAdress;
        di <= 4'b0000;
        ledOutput <= dout;

    end
end
*/

localparam UART_INTERVAL_SEND = 27000000/1; // 1 second
reg [31:0] txIntervalCounter = 0;

// UART
always @(posedge clk) begin
    if (txIntervalCounter == UART_INTERVAL_SEND) begin
        bramAddress <= receivedData;
        txIntervalCounter <= txIntervalCounter + 1;
        bramWre <= 0;
        bramReset <= 0;
        oce <= 1;
        ce <= 1;
        
    end else if (txIntervalCounter == UART_INTERVAL_SEND + 1) begin
        txIntervalCounter <= 0;
        sendOnLow <= 0;
        dataOut <= bramDout;
        
    end else begin
        txIntervalCounter <= txIntervalCounter + 1;
        sendOnLow <= 1;
    end
end

assign led = ~ledOutput;
endmodule
