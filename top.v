
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
reg bramReset; // TRY RESETTING IT BEFORE READING NEXT TIME
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
reg [7:0] uartDataOut;
reg sendOnLow;

uart usb(
    .clk(clk),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    //.led(led), 
    .dataOut(uartDataOut),
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

reg [7:0] writeCounter = 0;

// WRITE TO RAM
localparam TIME_BEFORE_RAM_WRITE = 27000000/5;
reg [31:0] timeBeforeRamWriteTimer = 0;
always @(posedge clk) begin
    if (timeBeforeRamWriteTimer == TIME_BEFORE_RAM_WRITE) begin
        // WRITE
        bramDin <= uartDataOut;
        bramWre <= 1;
        

        // write loop
        if (writeCounter == 16) begin
            timeBeforeRamWriteTimer <= timeBeforeRamWriteTimer + 1;
            // but we also need to write this one to ram
        end else begin
            bramDin <= writeCounter;
            bramAddress <= writeCounter;
            writeCounter <= writeCounter + 1'b1;
        end

    end else if (timeBeforeRamWriteTimer == TIME_BEFORE_RAM_WRITE + 1) begin
        // do nothing this should only run once
        // IF I ADD STUFF REMEMBER THIS
        bramWre <= 0;
    end else begin
        timeBeforeRamWriteTimer <= timeBeforeRamWriteTimer + 1;
    
    end

    // first stage of read
    if (txIntervalCounter == UART_INTERVAL_SEND) begin
        bramAddress <= receivedData;
        
        
        
        oce <= 1;
        ce <= 1;
        txIntervalCounter <= 0;

    end else begin
        txIntervalCounter <= txIntervalCounter + 1;
        
    end
end

// NEGEDGE
always @(negedge clk) begin
    if (txIntervalCounter == UART_INTERVAL_SEND) begin
        
        uartDataOut <= bramDout;
        sendOnLow <= 0;
    end else begin
        sendOnLow <= 1;
    end
end

assign led = ~ledOutput;
endmodule
