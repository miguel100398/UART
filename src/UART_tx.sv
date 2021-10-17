module UART_tx
import UART_pkg::*,
		 UART_csr_pkg::*;
(
    input  logic        clk,
    input  logic        rst_n,
    input  uart_data_t  tx_data,
    input  logic        send,
    output logic        tx_data_ready,
    output logic        tx,
    //CSR
    UART_csr_if.uart_mp csr,
    //Status flags
    output uart_busy_e  busy
);

logic wait_bit_done;
logic start_bits;
logic shift_bits;
logic wait_bit_en;
logic wait_bit_rst_n;

//FSM
UART_tx_fsm fsm(
    .clk(clk),
    .rst_n(rst_n),
    .send(send),
    .wait_bit_done(wait_bit_done),
    .tx_data_ready(tx_data_ready),
    .busy(busy),
    .start_bits(start_bits),
    .shift_bits(shift_bits),
    .wait_bit_en(wait_bit_en),
    .wait_bit_rst_n(wait_bit_rst_n),
    .csr(csr)
);

//Data path
UART_tx_datapath datapath(
    .clk(clk),
    .rst_n(rst_n),
    .start_bits(start_bits),
    .shift_bits(shift_bits),
    .wait_bit_en(wait_bit_en),
    .wait_bit_rst_n(wait_bit_rst_n),
    .tx_data(tx_data),
    .wait_bit_done(wait_bit_done),
    .tx(tx),
    .csr(csr)
);


endmodule: UART_tx