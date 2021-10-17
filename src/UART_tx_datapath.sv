module UART_tx_datapath
import UART_pkg::*;
(
    input  logic        clk,
    input  logic        start_bits,
    input  logic        shift_bits,
    input  logic        wait_bit_en,
    input  logic        wait_bit_rst_n,
    input  uart_data_t  tx_data,
    output logic        wait_bit_done,
    output logic        tx,
    //CSR
    UART_csr_if.uart_mp csr
);


logic[10:0] load_shift_reg_data;
logic parity_bit;
logic odd_parity;
logic even_parity;

//Shift register

shift_register#(
    .SHIFT_LEFT(1'b1),
    .WIDTH(11)          //{start_bit,data_bits[7:0], parity_bit, stop_bit}
) shft_reg(
    .clk(clk),
    .rst_n(1'b1),
    .data_in_p(load_shift_reg_data),
    .data_in_s(1'b1),
    .load(start_bits),
    .shift(shift_bits),
    .data_out_s(tx)
);

//BIT WAIT timer
timer#(
    .HALF_PULSE(1'b0),
    .WIDTH(32)
)(
    .clk(clk),
    .rst_n(wait_bit_rst_n),
    .count(csr.uart_baud_rate_csr),
    .en(wait_bit_en),
    .trigger(wait_bit_done)
);

//Calculate parity bit
assign even_parity = ~odd_parity;
assign parity_bit = (csr.uart_control_0_csr.odd_parity) ? odd_parity : even_parity;

always_comb begin
    case (csr.uart_control_0_csr.data_bits)
        4'd5: begin
            odd_parity          = ^tx_data[4:0];
            load_shift_reg_data = {UART_START_BIT, tx_data[4:0], parity_bit, UART_STOP_BIT, 3'b111};
        end
        4'd6: begin
            odd_parity          = ^tx_data[5:0];
            load_shift_reg_data = {UART_START_BIT, tx_data[5:0], parity_bit, UART_STOP_BIT, 2'b11};
        end
        4'd7: begin
            odd_parity          = ^tx_data[6:0];
            load_shift_reg_data = {UART_START_BIT, tx_data[6:0], parity_bit, UART_STOP_BIT, 1'b1};
        end
        4'd8: begin
            odd_parity          = ^tx_data[7:0];
            load_shift_reg_data = {UART_START_BIT, tx_data[7:0], parity_bit, UART_STOP_BIT};
        end
        default: begin
            odd_parity = 1'b0;
				load_shift_reg_data = 11'd0;
        end
    endcase
end


endmodule: UART_tx_datapath