//File:   seven_segment_decoder.sv
//author: Miguel Bucio miguel_angel_bucio@hotmail.com
//date:   september 4, 2021
//Description:
//          Decodes a 4bit hexadecimal signal to be displayed on a seven segment display


module seven_segment_decoder(
    input logic [3:0] decode,
    output logic [6:0] decoded
);

always_comb begin
    case(decode)
        0: decoded = 7'b1000000;
        1: decoded = 7'b1111001;
        2: decoded = 7'b0100100;
        3: decoded = 7'b0110000;
        4: decoded = 7'b0011001;
        5: decoded = 7'b0010010;
        6: decoded = 7'b0000010;
        7: decoded = 7'b1111000;
        8: decoded = 7'b0000000;
        9: decoded = 7'b0011000;
        10: decoded = 7'b0001000;
        11: decoded = 7'b0000011;
        12: decoded = 7'b1000110;
        13: decoded = 7'b0100001;
        14: decoded = 7'b0000100;
        15: decoded = 7'b0001110;
        default: decoded = 7'b1111111;
    endcase 
end

endmodule: seven_segment_decoder