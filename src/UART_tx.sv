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

assign tx_data_ready = rst_n;



endmodule: UART_tx