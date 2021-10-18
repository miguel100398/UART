//File:   pulse generator
//author: Miguel Bucio miguel_angel_bucio@hotmail.com
//date:   september 4, 2021
//Description:
//          Returns a pulse with a duration of 1 clk cycle every time the signal D is asserted

module pulse_generator(
    input logic clk,
    input logic D,
    output logic Q
);

    logic last_D; 

    always_ff @(posedge clk) begin
        last_D <= D;
        Q <= D & ~last_D;
    end

endmodule: pulse_generator