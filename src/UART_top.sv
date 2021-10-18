module UART_top
import UART_pkg::*,
       UART_csr_pkg::*;
(
    input  logic       clk,
    input  logic       rst_n,
    //Input data
    input  logic       rx,
    input  uart_data_t tx_data,
    input  logic       tx_send,
    input  logic       rx_flag_clr,
    //Output
    output logic       tx,
    output logic       parity_error,
    output logic       rx_flag,
    output logic[6:0]  displays[6]
);

genvar j;

uart_data_t rx_data;
logic[3:0]  rx_data_ascii_display;
logic[3:0]  displays_data[6];

UART uart_tx_rx(
    .clk(clk),
    .rst_n(rst_n),
    //Csr disabled
    .csr_wr_addr('b0),
    .csr_wr_data('b0),
    .csr_wen(1'b0),
    .csr_rd_addr('b0),
    .csr_ren(1'b0),
    //.csr_read_data(),
    //UART_TX
    .tx_data(tx_data),
    .tx_send(tx_send),
    //.tx_data_ready(),
    //UART_RX
    .rx_data(rx_data),
    .rx_flag(rx_flag),
    .rx_flag_clr(rx_flag_clr),
    .tx(tx),
    .rx(rx),
    .parity_error(parity_error)
);

ASCII_2_display asccii_display(
    .ASCII(rx_data),
    .display(rx_data_ascii_display)
);

//Shift data in display
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (int i=0; i<6; i++) begin
            displays_data[i] <= 4'd0;
        end
    end else if (rx_flag_clr) begin
        displays_data[0] <= rx_data_ascii_display;
        for(int i=1; i<6; i++) begin
            displays_data[i] <= displays_data[i-1];
        end
    end
end


//Displays
generate
    for (j=0; j<6; j++) begin : gen_displays 
        seven_segment_decoder decoder_(
            .decode(displays_data[j]),
            .decoded(displays[j])
        );
    end
endgenerate


endmodule: UART_top