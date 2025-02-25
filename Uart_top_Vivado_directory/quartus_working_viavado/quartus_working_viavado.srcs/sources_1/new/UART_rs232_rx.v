`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2024 21:44:12
// Design Name: 
// Module Name: UART_rs232_rx
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


module UART_rs232_rx (Clk,Rst_n,RxEn,RxData,RxDone,Rx,Tick,NBits);		//Define my module as UART_rs232_rx

input Clk, Rst_n, RxEn,Rx,Tick;		//Define 1 bit inputs
input [3:0]NBits;			//Define 4 bits inputs


output RxDone;				//Define 1 bit output
output [7:0]RxData;			//Define 8 bits output (this will eb the 1byte received data)


//Variabels used for state machine...
parameter  IDLE = 1'b0, READ = 1'b1; 	//We haev 2 states for the State Machine state 0 and 1 (READ adn IDLE)
reg [1:0] State, Next;			//Create some registers for the states
reg  read_enable = 1'b0;		//Variable that will enable or NOT the data in read
reg  start_bit = 1'b1;			//Variable used to notify when the start bit was detected (first falling edge of RX)
reg  RxDone ;			//Variable used to notify when the data read process is done
reg [4:0]Bit = 5'b00000;		//Variable used for the bit by bit read loop (in this case 8 bits so 8 loops)
reg [3:0] counter = 4'b0000;		//Counter variable used to count the tick pulses up to 16
reg [7:0] Read_data= 8'b00000000;	//Register where we store the Rx input bits before assigning it to the RxData output
reg [7:0] RxData;			//We register the output as well so we store the value





///////////////////////////////STATE MACHINE////////////////////////////////
////////////////////////////////////////////////////////////////////////////
///////////////////////////////////Reset////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
always @ (posedge Clk or negedge Rst_n)			//It is good to always have a reset always
begin
if (!Rst_n)	State <= IDLE;				//If reset pin is low, we get to the initial state which is IDLE
else 		State <= Next;				//If not we go to the next state
end




////////////////////////////////////////////////////////////////////////////
////////////////////////////Next step decision//////////////////////////////
////////////////////////////////////////////////////////////////////////////
/*This is easy. Each time "State or Rx or RxEn or RxDone" will change their value
we decide which is the next step. 
	- Obviously we get to IDLE only when RxDone is high
meaning that the read process is done.
	- Also, while we are into IDEL, we get to READ state only if Rx input gets low meaning
we've detected a start bit*/
always @ (State or Rx or RxEn or RxDone)
begin
    case(State)	
	IDLE:	if(!Rx & RxEn)		Next = READ;	 //If Rx is low (Start bit detected) we start the read process
		else			Next = IDLE;
	READ:	if(RxDone)		Next = IDLE; 	 //If RxDone is high, than we get back to IDLE and wait for Rx input to go low (start bit detect)
		else			Next = READ;
	default 			Next = IDLE;
    endcase
end






////////////////////////////////////////////////////////////////////////////
///////////////////////////ENABLE READ OR NOT///////////////////////////////
////////////////////////////////////////////////////////////////////////////
always @ (State or RxDone)
begin
    case (State)
	READ: begin
		read_enable <= 1'b1;			//If we are in the Read state, we enable the read process so in the "Tick always" we start getting the bits
	      end
	
	IDLE: begin
		read_enable <= 1'b0;			//If we get back to IDLE, we desable the read process so the "Tick always" could continue without geting Rx bits
	      end
	default: State<=IDLE;

    endcase
end





////////////////////////////////////////////////////////////////////////////
///////////////////////////Read the input data//////////////////////////////
////////////////////////////////////////////////////////////////////////////
/*Finally, each time we detect a Tick pulse,we increase a couter.
- When the counter is 8 (4'b1000) we are in the middle of the start bit
- When the counter is 16 (4'b1111) we are in the middle of one of the bits
- We store the data by shifting the Rx input bit into the Read_data register 
using this line of code: Read_data <= {Rx,Read_data[7:1]};
*/
always @ (posedge Tick)

	begin
			RxDone <= 1'b0;	
//	if(State==IDLE)
//	begin
//		RxDone <= 1'b0;							//Set the RxDone register to low since the process is still going
//    end
	
	if (read_enable)
	begin
	counter <= counter+1;						//Increase the counter by 1 with each Tick detected
	

	if ((counter == 4'b1000) & (start_bit))				//Counter is 8? Then we set the start bit to 1. 
	begin
	start_bit <= 1'b0;
	counter <= 4'b0000;
	end

	if ((counter == 4'b1111) & (!start_bit) & (Bit < NBits))	//We make a loop (8 loops in this case) and we read all 8 bits
	begin
	Bit <= Bit+1;
	Read_data <= {Rx,Read_data[7:1]};
	counter <= 4'b0000;
	end
	
	if ((counter == 4'b1111) & (Bit == NBits)  & (Rx))		//Then we count to 16 once again and detect the stop bit (Rx input must be high)
	begin
	Bit <= 4'b0000;
	RxDone <= 1'b1;
	counter <= 4'b0000;
	start_bit <= 1'b1;						//We reset all values for next data input and set RxDone to high
	end
	end
	
	

end


////////////////////////////////////////////////////////////////////////////
//////////////////////////////Output assign/////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/*Finally, we assign the Read_data register values to the RxData output and
that will be our final received value.*/
always @ (posedge RxDone)
begin

if (NBits == 4'b1000)
begin
RxData[7:0] <= Read_data[7:0];	
end

//if (NBits == 4'b0111)
//begin
//RxData[7:0] <= {1'b0,Read_data[7:1]};	
//end
//
//if (NBits == 4'b0110)
//begin
//RxData[7:0] <= {1'b0,1'b0,Read_data[7:2]};	
//end
end




//End of the RX mdoule
endmodule