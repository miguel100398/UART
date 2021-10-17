module UART_tx_fsm
import UART_tx_pkg::*,
		 UART_csr_pkg::*;
(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        send,
    input  logic        wait_bit_done,
    output logic        tx_data_ready,
    output uart_busy_e  busy,
    output logic        start_bits,
    output logic        shift_bits,
    output logic        wait_bit_en,
    output logic        wait_bit_rst_n,
    //CSR
    UART_csr_if.uart_mp csr
);

tx_state state, next_state;

//Bits that have been including start, stop, and parity bit
logic[3:0] bits_sent;
//Internal control signals
logic all_bits_sent;       //All bits have been sent {start, data_bits, parity, stop_bit}
logic bits_sent_en;        //Increment counter of bits sent
logic bits_sent_rst_n;    //Reset counter of bits sent  
logic use_parity_bit;     //Parity bit will be send
logic tx_data_ready_int;  //Assert data ready when state is idle

//Assert data ready when state is IDLE or 1 clk cycle before ending the transmission of the data
assign tx_data_ready = tx_data_ready_int || ((state==WAIT_BIT_S) && wait_bit_done && all_bits_sent);


//FSM sequential circuit
always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE_S;    
    end else begin
        state <= next_state;
    end    
end

//FSM next state logic
always_comb begin
    case(state)
        IDLE_S: begin
            next_state = (send) ? START_S : IDLE_S;
        end
        START_S: begin
            next_state = WAIT_BIT_S;
        end
        WAIT_BIT_S: begin
            if (wait_bit_done) begin
                if (~all_bits_sent) begin
                    next_state = SHIFT_BIT_S;       //Continue sending data bits
                end else begin
                    next_state = (send) ? START_S : IDLE_S;
                end
            end else begin
                next_state = WAIT_BIT_S;            //WAIT BIT
            end
        end
        SHIFT_BIT_S: begin
            next_state = WAIT_BIT_S;
        end
        default: begin
            next_state = IDLE_S;
        end
    endcase
end

//FSM outputs logic
always_comb begin
    case(state)
        IDLE_S: begin
            bits_sent_rst_n   = 1'b0;
            bits_sent_en      = 1'b0;
            tx_data_ready_int = 1'b1;
            busy              = UART_FREE;
            shift_bits        = 1'b0;
            wait_bit_en       = 1'b0;
            wait_bit_rst_n    = 1'b0;
            start_bits        = 1'b0;
        end
        START_S: begin
            bits_sent_rst_n   = 1'b0;
            bits_sent_en      = 1'b0;
            tx_data_ready_int = 1'b0;
            busy              = UART_BUSY;
            shift_bits        = 1'b0;
            wait_bit_en       = 1'b0;
            wait_bit_rst_n    = 1'b0;
            start_bits        = 1'b1;
        end
        WAIT_BIT_S: begin
            bits_sent_rst_n   = 1'b1;
            bits_sent_en      = 1'b0;
            tx_data_ready_int = 1'b0;
            busy              = UART_BUSY;
            shift_bits        = 1'b0;
            wait_bit_en       = 1'b1;
            wait_bit_rst_n    = 1'b1;
            start_bits        = 1'b0;
        end
        SHIFT_BIT_S: begin
            bits_sent_rst_n   = 1'b1;
            bits_sent_en      = 1'b1;
            tx_data_ready_int = 1'b0;
            busy              = UART_BUSY;
            shift_bits        = 1'b1;
            wait_bit_en       = 1'b0;
            wait_bit_rst_n    = 1'b0;
            start_bits        = 1'b0;
        end
        default: begin
            bits_sent_rst_n   = 1'b0;
            bits_sent_en      = 1'b0;
            tx_data_ready_int = 1'b0;
            busy              = UART_BUSY;
            shift_bits        = 1'b0;
            wait_bit_en       = 1'b0;
            wait_bit_rst_n    = 1'b0;
            start_bits        = 1'b0;
        end
    endcase
end

//Bits sent counter
always_ff @(posedge clk or negedge bits_sent_rst_n) begin
    if (~bits_sent_rst_n) begin
        bits_sent <= 4'd0;
    end else if (bits_sent_en) begin
        bits_sent <= bits_sent + 1'b1;
    end
end

//Control signals
assign use_parity_bit = (csr.uart_control_0_csr.parity_bit == UART_PARITY);
assign all_bits_sent  = (bits_sent == (csr.uart_control_0_csr.data_bits + use_parity_bit + 1'b1)); //{data bits + parity_bit + stop_bit} //Start bit resets counter

endmodule: UART_tx_fsm