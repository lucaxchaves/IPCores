`include "uart_states.vh"

module uart_tx #(
  parameter PAYLOAD_SIZE = 8
)(
    input  wire       clk,   
    input  wire       enable, 
    input  wire       start, 
    input  wire [PAYLOAD_SIZE-1:0] in,    
    output reg        out,   
    output reg        done,  
    output reg        busy
);
    parameter BIT_WIDTH = $clog2(PAYLOAD_SIZE);
    reg [2:0] state  = `RESET;
    reg [PAYLOAD_SIZE-1:0] data   = 0; 
    reg [BIT_WIDTH-1:0] bit_index  = 0; 
    reg [BIT_WIDTH-1:0] index;

    assign index = bit_index;

    always @(posedge clk) begin
        case (state)
            default     : begin
                state   <= `IDLE;
            end
            `IDLE       : begin
                out     <= 1'b1;
                done    <= 1'b0;
                busy    <= 1'b0;
                bit_index  <= 0;
                data    <= 0;
                if (start & enable) begin
                    data    <= in; 
                    state   <= `START_BIT;
                end
            end
            `START_BIT  : begin
                out     <= 1'b0; 
                busy    <= 1'b1;
                state   <= `DATA_BIT;
            end
            `DATA_BIT  : begin 
                out     <= data[index];
                if (&bit_index) begin
                    bit_index  <= 0;
                    state   <= `STOP_BIT;
                end else begin
                    bit_index  <= bit_index + 1'b1;
                end
            end
            `STOP_BIT   : begin 
                done    <= 1'b1;
                data    <= 8'b0;
                state   <= `IDLE;
            end
        endcase
    end

endmodule
