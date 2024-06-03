`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2024 15:57:13
// Design Name: 
// Module Name: fifo_8bit
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


module fifo_8bit( 
   input Rst_n,
   input  [7:0] RxData,
   input  RxDone,
   input   TxDone,
	output [4:0] wr_ptr1,
   output  [7:0] TxData

    );
    
reg [255:0] tx_data_reg;  // 16-bit register to store incoming data
reg [4:0] wr_ptr ,rd_ptr = 5'b0;
reg [7:0] TxData1;   

assign wr_ptr1=wr_ptr;
    
always@(posedge RxDone or negedge Rst_n)
begin
if(!Rst_n)
begin
tx_data_reg <= 255'b0;
wr_ptr<=5'b0;
end
else begin
    tx_data_reg [wr_ptr * 8 +: 8] <= RxData;
   wr_ptr<=wr_ptr+1'b1;
end
end
    
always@(posedge TxDone or negedge Rst_n)
begin
if(!Rst_n)
begin
 rd_ptr<=5'b0;
 end
 else begin
 	TxData1 <= tx_data_reg[rd_ptr * 8 +: 8];
    rd_ptr<=rd_ptr+1'b1;
 end
end
    
	 
	 
assign TxData=TxData1;
    
endmodule
