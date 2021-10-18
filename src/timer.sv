module timer#(
    parameter bit HALF_PULSE     = 0,
    parameter int unsigned WIDTH = 32
)(
    input  logic            clk,
    input  logic            rst_n,
    input  logic[WIDTH-1:0] count,
    input  logic            en,
    output logic            half_trigger,   //Can´t remove port with parameter, will be removed in synthesis by quartus
    output logic            trigger
);

logic[WIDTH-1:0] cntr;
logic[WIDTH-1:0] next_cntr;

assign next_cntr = cntr + 1'b1;

//Trigger
assign trigger = (next_cntr === count);
//half trigger
generate
    if (HALF_PULSE) begin: gen_half_trigger
        assign half_trigger = (next_cntr == (count>>1));
    end
    //Else
    //Unused outputs will be removed by quartus in synthesis
endgenerate

//Counter
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cntr <= {WIDTH{1'b0}};
    end else if (en) begin
        if (trigger) begin
            cntr <= {WIDTH{1'b0}};
        end else begin
            cntr <= next_cntr;
        end
    end
end

endmodule: timer