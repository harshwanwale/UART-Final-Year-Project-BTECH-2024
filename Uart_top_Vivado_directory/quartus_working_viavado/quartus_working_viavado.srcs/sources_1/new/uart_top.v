module uart_top(
       start_tx                  ,
//       TxData                  ,
    	Clk                     ,
    	Rst_n                   ,   
     	Rx                      ,    
    	Tx                      ,
	    RxData		                 
	);

/////////////////////////////////////////////////////////////////////////////////

//input   [7:0]   TxData          ;
input    start_tx            ;
input           Clk             ; // Clock
input           Rst_n           ; // Reset
input           Rx              ; // RS232 RX line.
output          Tx              ; // RS232 TX line.
output [7:0]    RxData          ; // Received data



/////////////////////////////////////////////////////////////////////////////////////////



wire [7:0]    	TxData     	; // Data to transmit.
wire          	RxDone          ; // Reception completed. Data is valid.
wire          	TxDone          ; // Trnasmission completed. Data sent.
wire            tick		; // Baud rate clock
wire          	TxEn            ;
wire 		RxEn		;
wire [3:0]      NBits    	;
wire [15:0]    	BaudRate        ; //328; 162 etc... (Read comment in baud rate generator file)
wire [4:0] wr_ptr;
wire pulse;

/////////////////////////////////////////////////////////////////////////////////////////



assign 		RxEn = 1'b1	;
assign 		TxEn = 1'b1	;
assign 		BaudRate = 16'd1; 	//baud rate set to 9600 for the HC-06 bluetooth module. Why 325? (Read comment in baud rate generator file)
assign 		NBits = 4'b1000	;	//We send/receive 8 bits
/////////////////////////////////////////////////////////////////////////////////////////


//Make connections between Rx module and TOP inputs and outputs and the other modules
UART_rs232_rx I_RS232RX(
    	.Clk(Clk)             	,
   	    .Rst_n(Rst_n)         	,
    	.RxEn(RxEn)           	,
    	.RxData(RxData)       	,
    	.RxDone(RxDone)       	,
    	.Rx(Rx)               	,
    	.Tick(tick)           	,
    	.NBits(NBits)
    );
	 
	 

//Make connections between Tx module and TOP inputs and outputs and the other modules
UART_rs232_tx I_RS232TX(
   	.Clk(Clk)            	,
   	.pulse(pulse)           ,
   	.start_tx(start_tx)     ,
   	.wr_ptr(wr_ptr)         ,
    .Rst_n(Rst_n)         	,
    .TxEn(TxEn)           	,
    .RxDone(RxDone)         ,
    .TxData(TxData)      	,
   	.TxDone(TxDone)      	,
   	.Tx(Tx)               	,
   	.Tick(tick)           	,
   	.NBits(NBits)
    );
    
fifo_8bit fifo_inst1( 
   .Rst_n(Rst_n),
   .pulse(pulse),
   .wr_ptr1(wr_ptr),
   .RxData(RxData),
   .RxDone(RxDone),
   .TxDone(TxDone),
   .TxData(TxData)

    );

//Make connections between tick generator module and TOP inputs and outputs and the other modules
UART_BaudRate_generator I_BAUDGEN(
    	.Clk(Clk)               ,
    	.Rst_n(Rst_n)           ,
    	.Tick(tick)             ,
    	.BaudRate(BaudRate)
    );
endmodule