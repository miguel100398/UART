//Description: UART control status registers
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 4/10/2021



module UART
import UART_pkg::*,
	   UART_csr_pkg::*;
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
    output uart_csr_data_t csr_rd_data,
    //UART Internal interface
    input  uart_data_t     tx_data,
    input  logic           send,
    output logic           tx_data_ready,
    output uart_data_t     rx_data,
    output logic           rx_data_valid,
    input  logic           rx_data_ready,
    //UART external interface
    output logic           tx,
    input  logic           rx
    
);

//CSR interface
	UART_csr_if csr_if();

    //Status flags
    uart_busy_e uart_busy_f;
    logic uart_parity_error_f;
	
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
        .csr(csr_if.csr_mp),
        .parity_error(uart_parity_error_f),
        .busy(uart_busy_f)
    );
	 
	  //UART tx
    UART_tx tx0(
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .send(send),
        .tx_data_ready(tx_data_ready),
        .tx(tx),
        .csr(csr_if.uart_mp),
        .busy(uart_busy_f)
    );


    //AURT rx
    UART_rx rx0(
        .clk(clk),
        .rst_n(rst_n),
        .rx_data(rx_data),
        .rx_data_valid(rx_data_valid),
        .rx_data_ready(rx_data_ready),
        .rx(rx),
        .csr(csr_if.uart_mp),
        .parity_error(uart_parity_error_f)
    );
    

endmodule: UART