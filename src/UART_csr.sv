//Description: UART control status registers
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 4/10/2021



module UART_csr
import UART_csr_pkg::*;
(
    //CSR interface to exterior
    input  logic           clk,
    input  logic           rst_n,
    input  uart_csr_addr_t wr_addr,
    input  uart_csr_data_t wr_data,
    input  logic           wen,
    input  uart_csr_addr_t rd_addr,
    output uart_csr_data_t rd_data,
    input  logic           ren,
    //CSR interface to UART sub modules
    UART_csr_if.csr_mp    csr,
    //Status flags
    input logic           parity_error,
    input uart_busy_e     busy
);

//Registers
uart_baud_rate_csr_t uart_baud_rate_csr;
uart_control_0_csr_t uart_control_0_csr;
uart_status_0_csr_t  uart_status_0_csr;
//Write enables
logic write_uart_baud_rate_csr;
logic write_uart_control_0_csr;
//Read registers
logic read_uart_status_0_csr;
//Error in data bits
logic data_bit_error;

//Assign registers to interfaces
assign csr.uart_baud_rate_csr = uart_baud_rate_csr;
assign csr.uart_control_0_csr = uart_control_0_csr;
assign csr.uart_status_0_csr  = uart_status_0_csr;

//Write enables
assign write_uart_baud_rate_csr = wen && (wr_addr == UART_BAUD_RATE_CSR_ADDR);
assign write_uart_control_0_csr = wen && (wr_addr == UART_CONTROL_0_CSR_ADDR);
//Read clean
assign read_uart_status_0_csr  = ren && (rd_addr == UART_STATUS_0_CSR_ADDR);

//Registers
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        uart_baud_rate_csr <= UART_BAUD_RATE_CSR_RST;
    end else if (write_uart_baud_rate_csr) begin
        uart_baud_rate_csr <= wr_data;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        uart_control_0_csr <= UART_CONTROL_0_CSR_RST;
    end else if (write_uart_control_0_csr) begin
        uart_control_0_csr <= wr_data;
    end
end

//Error in data bits
assign data_bit_error = (uart_control_0_csr.data_bits < 5) || (uart_control_0_csr.data_bits > 8);

//Quartus will infer latches for dont_care bits as they are never written,
//These latches are expected
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        uart_status_0_csr <= UART_STATUS_0_CSR_RST;
    end else if (read_uart_status_0_csr) begin      //clean bits with read
        uart_status_0_csr.data_bits_error <= UART_NO_ERROR;
        uart_status_0_csr.parity_error    <= UART_NO_ERROR;
    end else begin
        //Write flags
        if (data_bit_error) begin
            uart_status_0_csr.data_bits_error <= UART_ERROR;
        end
        if (parity_error) begin
            uart_status_0_csr.parity_error    <= UART_ERROR;
        end
        uart_status_0_csr.busy                <= busy;
    end
end

//Read register
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rd_data <= {UART_CSR_DATA_WIDTH{1'b0}};
    end else if (ren) begin
        case (rd_addr)
            UART_BAUD_RATE_CSR_ADDR: begin
                rd_data <= uart_baud_rate_csr;
            end
            UART_CONTROL_0_CSR_ADDR: begin
                rd_data <= uart_control_0_csr;
            end
            UART_STATUS_0_CSR_ADDR: begin
                rd_data <= uart_status_0_csr;
            end
            default: begin
                rd_data <= {UART_CSR_DATA_WIDTH{1'b0}};
            end
        endcase
    end
end


endmodule: UART_csr