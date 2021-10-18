module UART_rx_datapath
import UART_csr_pkg::*,
		 UART_pkg::*;
(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx,
    input  logic        shift_bits,
    input  logic        wait_bit_en,
    input  logic        wait_bit_rst_n,
    input  logic        done,
    input  logic        rx_data_ready,
    output logic        wait_bit_done,
    output uart_data_t  rx_data,
    output logic        parity_error,
    output logic        rx_data_valid,
    //CSR
    UART_csr_if.uart_mp csr
);

logic sample_rx;
logic [8:0] shift_reg;
logic [7:0] shift_reg_no_parity;
logic rx_sampled;
logic odd_parity;
logic even_parity;
logic parity;
logic check_parity;
logic check_odd;

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rx_sampled <= 1'b0;
    end
    else if (sample_rx) begin
        rx_sampled <= rx;    
    end    
end


//wait bit timer
timer#(
    .HALF_PULSE(1'b1),
    .WIDTH(32)
)wait_bit_timer(
    .clk(clk),
    .rst_n(wait_bit_rst_n),
    .count(csr.uart_baud_rate_csr),
    .en(wait_bit_en),
    .half_trigger(sample_rx),
    .trigger(wait_bit_done)
);


//Shift register
shift_register#(
    .SHIFT_LEFT(1'b1),
    .WIDTH(9)          //{data_bits[7:0] parity_bit}
) shft_reg(
    .clk(clk),
    .rst_n(rst_n),
    .data_in_p(9'd0),
    .data_in_s(rx_sampled),
    .load(1'b0),
    .shift(shift_bits),
    .data_out_p(shift_reg)
);

assign shift_reg_no_parity = (csr.uart_control_0_csr.parity_bit) ? shift_reg[8:1] : shift_reg[7:0];

//Data out
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        parity       <= 1'b0;
        check_parity <= 1'b0;
        check_odd    <= 1'b0;
        rx_data      <= 8'd0;
    end else if (done) begin
        parity       <= shift_reg[0];
        check_parity <= csr.uart_control_0_csr.parity_bit;
        check_odd    <= csr.uart_control_0_csr.odd_parity;
        case(csr.uart_control_0_csr.data_bits)
            4'd5: begin
                rx_data    <= {3'd0, shift_reg_no_parity[4:0]};
            end
            4'd6: begin
                rx_data    <= {2'd0, shift_reg_no_parity[5:0]};
            end
            4'd7: begin
                rx_data    <= {1'd0, shift_reg_no_parity[6:0]};
            end
            4'd8: begin
                rx_data    <= {shift_reg_no_parity[7:0]};
            end
        endcase
    end 
end

assign even_parity  = ^rx_data;
assign odd_parity  = ~even_parity;

//Parity_error
always_comb begin
    if (check_parity) begin
        parity_error = (check_odd) ? (parity != odd_parity) : (parity != even_parity);
    end else begin
	     parity_error = 1'b0;
	 end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rx_data_valid <= 1'b0;
    end else if (done) begin
        rx_data_valid <= 1'b1;
    end else if (rx_data_ready) begin
        rx_data_valid <= 1'b0;
    end
end

endmodule: UART_rx_datapath