module shift_register#(
    parameter bit SHIFT_LEFT     = 1'b1,
    parameter int unsigned WIDTH = 8
)(
    input  logic            clk,
    input  logic            rst_n,
    input  logic[WIDTH-1:0] data_in_p,
    input  logic            data_in_s,
    input  logic            load,
    input  logic            shift,
    output logic[WIDTH-1:0] data_out_p,
    output logic            data_out_s
);

localparam bit SHIFT_RIGHT = ~SHIFT_LEFT;

logic [WIDTH-1:0] shift_reg;
logic [WIDTH-1:0] next_shift_reg;

assign data_out_p = shift_reg;

generate
    if (SHIFT_LEFT) begin : gen_shift_register_left 
        assign next_shift_reg = {shift_reg[WIDTH-2:0], data_in_s};   //shift_reg << 1 + data_in
        assign data_out_s     = shift_reg[WIDTH-1];
    end else begin : gen_shift_register_right 
        assign next_shift_reg = {data_in_s, shift_reg[WIDTH-1:1]};  //data_in + Shift_reg >> 1 
        assign data_out_s     = shift_reg[0];
    end 
endgenerate

//Register
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        shift_reg <= {WIDTH{1'b0}};
    end else begin
        if (load) begin
            shift_reg <= data_in_p;
        end else if (shift) begin
            shift_reg <= next_shift_reg;
        end
    end
end

endmodule: shift_register   