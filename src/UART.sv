module UART
import UART_pkg::*;
(
    //Clock and resets
    input  logic           clk,
    input  logic           rst_n,
    //CSR signals
    input  uart_csr_addr_t csr_wr_addr,
    input  uart_csr_data_t csr_wr_data,
    input  logic           csr_wen,
    input  uart_csr_addr_t csr_rd_addr,
    input  logic           csr_ren,
    output uart_csr_data_t csr_rd_data
);

    //CSR interface
    UART_csr_if csr_if();

    //CSR
    UART_csr csr(
        .clk(clk),
        .rst_n(rst_n),
        .wr_addr(csr_wr_addr),
        .wr_data(csr_wr_data),
        .wen(csr_wen),
        .rd_addr(csr_rd_addr),
        .rd_data(csr_rd_data),
        .ren(csr_ren),
        .regs(csr_if.csr_mp)
    );

    //UART tx
    UART_tx tx();

    //AURT rx
    UART_rx rx();


endmodule: UART