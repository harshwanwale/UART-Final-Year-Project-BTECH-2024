`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2024 21:46:21
// Design Name: 
// Module Name: Uart_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Uart_top_tb;

//reg [7:0] TxData;
reg Clk;
reg start_tx;
reg Rst_n;
reg Rx;
wire Tx;
wire [7:0]  RxData;

uart_top inst_1_top ( 
    .start_tx(start_tx),
//    .TxData(TxData),
    .Clk(Clk),
    .Rst_n(Rst_n),
    .Rx(Rx),
    .Tx(Tx),
    .RxData(RxData)
);

// Clock toggling
always #1 Clk = ~Clk;

// Initial block for reset and clock initialization
initial begin
    Clk = 0;
    Rst_n = 0;
    start_tx=1;
    #5 Rst_n = 1;
    
//   #50 TxData = 8'b11001100; // Example test data
//     #5 start_tx = 0;
//    #5 start_tx = 1;
    
//     #600   
//     #50 TxData = 8'b11000100; // Example test data
//     #100
//    #5 start_tx = 0;
//    #5 start_tx = 1;
    #64 Rx=0;
    #64 Rx=1;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=1;
    #64 Rx=1;
#100
//      #5 start_tx = 0;
//    #5 start_tx = 1;
    
    #64 Rx=1;
    #64 Rx=0;
    #64 Rx=1;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=0;
    #64 Rx=1;
    #64 Rx=1;
     #64 Rx=1;


#300
      #5 start_tx = 0;
    #5 start_tx = 1;
    #300
    #300
    #300
          #5 start_tx = 0;
    #5 start_tx = 1;
    
       #300
    #300
    #300
          #5 start_tx = 0;
    #5 start_tx = 1;
    
    
//       #5 Rst_n=0;
//    #5 Rst_n=1;
//     Test data generation
//    TxData = 8'b11001100; // Example test data
    
//    #5 Rst_n=1;
//    #5 Rst_n=0;
//    #5 Rst_n=1;
    
    
//     Monitor for observing signals
//    $monitor("Time=%0t TxData=%h Clk=%b Rst_n=%b Rx=%b Tx=%b RxData=%h", $time, TxData, Clk, Rst_n, Rx, Tx, RxData);
    
//     Finish simulation after some time
    #1000 $finish;
end

endmodule

