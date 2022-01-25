`include "uart_states.vh"

module uart_rx #(
  parameter PAYLOAD_SIZE = 8
)(
    input  wire       clk,  
    input  wire       enable,
    input  wire       in,   
    output reg  [PAYLOAD_SIZE-1:0] out,  
    output reg        done,
    output reg        busy, 
    output reg        error   
);
  parameter BIT_WIDTH = $clog2(PAYLOAD_SIZE);

  reg [2:0] state;
  reg [BIT_WIDTH-1:0] bit_index = 0; 
  reg [1:0] input_sw = 2'b0; 
  reg [3:0] clock_count = 4'b0;
  reg [PAYLOAD_SIZE-1:0] received_data = 0;

  initial begin
    out <= 0;
    error <= 1'b0;
    done <= 1'b0;
    busy <= 1'b0;
  end

  always @(posedge clk) begin
    input_sw = { input_sw[0], in };

    if (!enable) begin
      state = `RESET;
    end

    case (state)
      `RESET: begin
        out <= 0;
        error <= 1'b0;
        done <= 1'b0;
        busy <= 1'b0;
        bit_index <= 0;
        clock_count <= 4'b0;
        received_data <= 8'b0;
        if (enable) begin
          state <= `IDLE;
        end
      end

      `IDLE: begin
        done <= 1'b0;
        if (&clock_count) begin
          state <= `DATA_BIT;
          out <= 0;
          bit_index <= 0;
          clock_count <= 4'b0;
          received_data <= 8'b0;
          busy <= 1'b1;
          error <= 1'b0;
        end else if (!(&input_sw) || |clock_count) begin
          if (&input_sw) begin
            error <= 1'b1;
            state <= `RESET;
          end
          clock_count <= clock_count + 4'b1;
        end
      end

      `DATA_BIT: begin
        if (&clock_count) begin 
          clock_count <= 4'b0;
          received_data[bit_index] <= input_sw[0];
          if (&bit_index) begin
            bit_index <= 0;
            state <= `STOP_BIT;
          end else begin
            bit_index <= bit_index + 1;
          end
        end else begin
          clock_count <= clock_count + 4'b1;
        end
      end

      `STOP_BIT: begin
        if (&clock_count || (clock_count >= 4'h8 && !(|input_sw))) begin
          state <= `IDLE;
          done <= 1'b1;
          busy <= 1'b0;
          out <= received_data;
          clock_count <= 4'b0;
        end else begin
          clock_count <= clock_count + 1;
          if (!(|input_sw)) begin
            error <= 1'b1;
            state <= `RESET;
          end
        end
      end

      default: state <= `IDLE;
    endcase
  end
endmodule