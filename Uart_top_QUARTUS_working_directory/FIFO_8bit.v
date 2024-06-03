module FIFO_8bit (
    input wire clk,        // Clock signal
    input wire wr_en,      // Write enable signal
    input wire rst,        // Reset signal
    input wire start_tx,   // Start transmission signal
    input wire data_in,    // Input data (8 bits)
    output reg [7:0] data_out    // Output data (8 bits)
);

    reg [127:0] fifo_reg;  // FIFO register with depth 16 (16 * 8 = 128 bits)
    reg [3:0] write_ptr, read_ptr;  // Write and read pointers
    reg [1:0] R_edge;      // Register for edge detection
    wire D_edge;           // Edge detection signal

    // Write operation (input data into FIFO)
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            fifo_reg <= 128'b0;
            write_ptr <= 4'b0;
        end else if (wr_en && write_ptr < 16) begin
            fifo_reg[write_ptr * 8 +: 8] <= data_in;
            write_ptr <= write_ptr + 1;
        end
    end

    // Read operation (output data from FIFO)
    always @(posedge clk) begin
        if (!start_tx && write_ptr > read_ptr ) begin
            data_out <= fifo_reg[read_ptr * 8 +: 8];
            read_ptr <= read_ptr + 1;
        end
    end

    // Edge detection logic
    always @(posedge clk or negedge start_tx) begin
        if (!start_tx) begin
            R_edge <= 2'b00;
        end else begin
            R_edge <= {R_edge[0], start_tx};
        end
    end

    assign D_edge = !R_edge[1] & R_edge[0];

endmodule
