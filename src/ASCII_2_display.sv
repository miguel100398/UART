module ASCII_2_display(
    input  logic[7:0] ASCII,
    output logic[3:0] display
);

always_comb begin 
    case(ASCII) 
        8'd48: display = 4'h0;
        8'd49: display = 4'h1;
        8'd50: display = 4'h2;
        8'd51: display = 4'h3;
        8'd52: display = 4'h4;
        8'd53: display = 4'h5;
        8'd54: display = 4'h6;
        8'd55: display = 4'h7;
        8'd56: display = 4'h8;
        8'd57: display = 4'h9;
        8'd65: display = 4'hA;
        8'd66: display = 4'hB;
        8'd67: display = 4'hC;
        8'd68: display = 4'hD;
        8'd69: display = 4'hE;
        8'd70: display = 4'hF;
        default: display = 4'h0;
    endcase
end

endmodule: ASCII_2_display