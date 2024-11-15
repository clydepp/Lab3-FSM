module f1light #(
    parameter T_WIDTH = 16
)(
    input logic en,
    input logic rst,
    input logic clk,
    input logic [T_WIDTH-1:0] N,
    output logic [7:0] data_out
);

logic tick;

clktick #(T_WIDTH) clock (
    .clk (clk),
    .rst (rst),
    .en (en),
    .N (N),
    .tick (tick)
);

f1_fsm states (
    .rst (rst),
    .en (tick),
    .clk (clk),
    .data_out (data_out)
);

endmodule
