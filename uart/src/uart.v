
`include "uart_rx.v"
`include "uart_tx.v"
`include "uart_baud_rate_generator.v"


module uart #(
  parameter CLK_HZ = 50_000_000,
  parameter BAUD_RATE = 9600,
  parameter PAYLOAD_SIZE = 8
)(
  input wire clk,

  //RX interface
  input wire rx,
  input wire rx_enable,
  output wire [7:0] out,
  output wire rx_done,
  output wire rx_busy,
  output wire rx_error,
  
  //TX interface
  output wire tx,
  input wire tx_enable,
  input wire tx_start,
  input wire [7:0] in,
  output wire tx_done,
  output wire tx_busy
);


  wire rx_clk;
  wire tx_clk;

  
  uart_baud_rate_generator #(
    .CLK_HZ(CLK_HZ),
    .BAUD_RATE(BAUD_RATE)
  ) i_uart_baud_rate_generator (
    .clk(clk),
    .rx_clk(rx_clk),
    .tx_clk(tx_clk)
  );

  uart_rx #(
    .PAYLOAD_SIZE(PAYLOAD_SIZE)
  ) i_uart_rx (
    .clk(rx_clk),
    .enable(rx_enable),
    .in(rx),
    .out(out),
    .done(rx_done),
    .busy(rx_busy),
    .error(rx_error)
  );

  uart_tx #(
    .PAYLOAD_SIZE(PAYLOAD_SIZE)
  ) i_uart_tx (
    .clk(tx_clk),
    .enable(tx_enable),
    .start(tx_start),
    .in(in),
    .out(tx),
    .done(tx_done),
    .busy(tx_busy)
);
endmodule
