module UART_BaudRate_generator(
    Clk,
    Rst_n,
    Tick,
    BaudRate
);

input           Clk;         // Clock input
input           Rst_n;       // Active low reset input
input [15:0]    BaudRate;    // Baud rate divisor
output          Tick;        // Tick pulse output

reg [15:0]      baudRateReg; // Baud rate counter register

// Always block triggered on the rising edge of the clock or falling edge of reset
always @(posedge Clk or negedge Rst_n) begin
    if (!Rst_n) 
        baudRateReg <= 16'b1; // Reset counter to 1
    else if (Tick) 
        baudRateReg <= 16'b1; // Reset counter to 1 when tick occurs
    else 
        baudRateReg <= baudRateReg + 1'b1; // Increment counter
end

// Generate tick pulse when the counter reaches the BaudRate value
assign Tick = (baudRateReg == BaudRate);

endmodule
