module uart_baud_rate_generator #(
  parameter CLK_HZ = 50_000_000,
  parameter BAUD_RATE = 9600  
)(
  input wire clk,
  output reg rx_clk,
  output reg tx_clk
);

  parameter MAX_RATE_RX = CLK_HZ / (2 * BAUD_RATE * 16); // 16x oversample
  parameter MAX_RATE_TX = CLK_HZ / (2 * BAUD_RATE);
  parameter RX_CNT_WIDTH = $clog2(MAX_RATE_RX);
  parameter TX_CNT_WIDTH = $clog2(MAX_RATE_TX);

  reg [RX_CNT_WIDTH - 1:0] rx_counter = 0;
  reg [TX_CNT_WIDTH - 1:0] tx_counter = 0;

  initial begin
    rx_clk = 1'b0;
    rx_clk = 1'b0;
  end

always @(posedge clk) begin
    // rx clock
    if (rx_counter == MAX_RATE_RX[RX_CNT_WIDTH-1:0]) begin
        rx_counter <= 0;
        rx_clk <= ~rx_clk;
    end else begin
        rx_counter <= rx_counter + 1'b1;
    end
    // tx clock
    if (tx_counter == MAX_RATE_TX[TX_CNT_WIDTH-1:0]) begin
        tx_counter <= 0;
        tx_clk <= ~tx_clk;
    end else begin
        tx_counter <= tx_counter + 1'b1;
    end
end

endmodule
