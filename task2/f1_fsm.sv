module f1_fsm (
    input   logic       rst,
    input   logic       en,
    input   logic       clk,
    output  logic [7:0] data_out
);

    typedef enum {S0, S1, S2, S3, S4, S5, S6, S7, S8} light_state;
    light_state current_state, next_state;

//     always_ff @ (posedge clk)
//         if (rst | current_state==S0) count <= randval - 1'b1;
//         else if (current_state==S8) count <= count - 1'b1;

    always_ff @(posedge clk, posedge rst)
        if (rst) current_state <= S0;
        else if (en) current_state <= next_state;

    // state logic
    always_comb begin
        case (current_state)
            S0:     next_state = S1;
            S1:     next_state = S2;
            S2:     next_state = S3;
            S3:     next_state = S4;
            S4:     next_state = S5;
            S5:     next_state = S6;
            S6:     next_state = S7;
            S7:     next_state = S8;
            S8:     next_state = S0;
            default: next_state = current_state;                 
        endcase
    end

    // outputs (lights)
    always_comb begin
        case (current_state)
            S0:     data_out = {8'b00000000};
            S1:     data_out = {8'b00000001};
            S2:     data_out = {8'b00000011};
            S3:     data_out = {8'b00000111};
            S4:     data_out = {8'b00001111};
            S5:     data_out = {8'b00011111};
            S6:     data_out = {8'b00111111};
            S7:     data_out = {8'b01111111};
            S8:     data_out = {8'b11111111};
            default: data_out = {8'b00000000};
        endcase
    end

endmodule