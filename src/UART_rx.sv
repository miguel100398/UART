module UART_rx
import UART_pkg::*,
       UART_csr_pkg::*;
(
    
    input  logic        clk,
    input  logic        rst_n,
    input  logic        rx_data_ready,
    output uart_data_t  rx_data,
    output logic        rx_data_valid,
    input  logic        rx,
    output logic        parity_error,
    //CSR
    UART_csr_if.uart_mp csr
    
);


logic wait_bit_done;
logic start_bits;
logic shift_bits;
logic wait_bit_en;
logic wait_bit_rst_n;
logic done;

//FSM
UART_rx_fsm fsm(
    .clk(clk),
    .rst_n(rst_n),
    .rx(rx),
    .wait_bit_done(wait_bit_done),
    .shift_bits(shift_bits),
    .wait_bit_en(wait_bit_en),
    .wait_bit_rst_n(wait_bit_rst_n),
    .done(done),
    .csr(csr)
);

//Datapath
UART_rx_datapath datapath(
    .clk(clk),
    .rst_n(rst_n),
    .rx(rx),
    .shift_bits(shift_bits),
    .wait_bit_en(wait_bit_en),
    .wait_bit_rst_n(wait_bit_rst_n),
    .done(done),
    .rx_data_ready(rx_data_ready),
    .wait_bit_done(wait_bit_done),
    .rx_data(rx_data),
    .parity_error(parity_error),
    .rx_data_valid(rx_data_valid),
    .csr(csr)
);


endmodule: UART_rx