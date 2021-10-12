module UART_rx
import UART_pkg::*;
(
    
    input  logic        clk,
    input  logic        rst_n,
    output uart_data_t  rx_data,
    output logic        rx_data_valid,
    input  logic        rx,
    UART_csr_if.uart_mp csr,
    output logic        parity_error
    
);

assign rx_data = rst_n;


endmodule: UART_rx