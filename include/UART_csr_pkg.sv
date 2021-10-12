//Description: UART package, defines common types and parameters used by UART CSR
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 4/10/2021
//Parameters:

package UART_csr_pkg;

//Registers parameters and typedefs
parameter  int unsigned NUM_UART_CSR        = 3;
parameter  int unsigned UART_CSR_DATA_WIDTH = 32;
localparam int unsigned UART_CSR_ADDR_WIDTH = $clog2(NUM_UART_CSR);
typedef logic [UART_CSR_ADDR_WIDTH-1:0] uart_csr_addr_t;
typedef logic [UART_CSR_DATA_WIDTH-1:0] uart_csr_data_t;
//FIeld parameters enums
typedef enum logic {UART_NO_PARITY = 1'b0,   UART_PARITY = 1'b1}     uart_set_parity_e;
typedef enum logic {UART_EVEN_PARITY = 1'b0, UART_ODD_PARITY = 1'b1} uart_parity_e;
typedef enum logic {UART_NO_ERROR = 1'b0,    UART_ERROR = 1'b1}      uart_error_e;
typedef enum logic {UART_FREE = 1'b0,        UART_BUSY = 1'b1}       uart_busy_e;
//Dont care bits
parameter int unsigned UART_BAUD_RATE_CSR_DONT_CARE_BITS = 0;
parameter int unsigned UART_CONTROL_0_CSR_DONT_CARE_BITS = UART_CSR_DATA_WIDTH - 6;
parameter int unsigned UART_STATUS_0_CSR_DONT_CARE_BITS  = UART_CSR_DATA_WIDTH - 3;
//Registers
typedef struct packed {
    uart_csr_data_t baud_rate;
} uart_baud_rate_csr_t;
typedef struct packed {
    logic [UART_CONTROL_0_CSR_DONT_CARE_BITS-1:0] dont_care;
    logic [3:0]                                   data_bits;
    uart_parity_e                                 odd_parity;
    uart_set_parity_e                             parity_bit;
} uart_control_0_csr_t;
typedef struct packed {
    logic[UART_STATUS_0_CSR_DONT_CARE_BITS-1:0] dont_care;
    uart_error_e                                data_bits_error;
    uart_error_e                                parity_error;
    uart_busy_e                                 busy;
} uart_status_0_csr_t;

//Addresses
parameter uart_csr_addr_t UART_BAUD_RATE_CSR_ADDR = 'h0;
parameter uart_csr_addr_t UART_CONTROL_0_CSR_ADDR = 'h1;
parameter uart_csr_addr_t UART_STATUS_0_CSR_ADDR  = 'h2;
//Reset values
parameter uart_csr_data_t UART_BAUD_RATE_CSR_RST = 'd9600;
//Dont care bits/Data bits/od_parity/parity_bit
//XXXXXXXXXXXXXX/   8     /  ODD    / PARITY
parameter uart_csr_data_t UART_CONTROL_0_CSR_RST = {{UART_CONTROL_0_CSR_DONT_CARE_BITS{1'b0}}, 4'd8, UART_ODD_PARITY, UART_PARITY}; 
//Dont carebits/data_bits_error/parity_error/busy
//XXXXXXXXXXXXX/  NO_ERROR     / NO_ERROR  / FREE
parameter uart_csr_data_t UART_STATUS_0_CSR_RST = {{UART_STATUS_0_CSR_DONT_CARE_BITS{1'b0}}, UART_NO_ERROR, UART_NO_ERROR, UART_FREE};


endpackage: UART_csr_pkg