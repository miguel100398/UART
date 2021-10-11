interface UART_csr_if;
import UART_pkg::*;

//Registers
uart_baud_rate_csr_t uart_baud_rate_csr;
uart_control_0_csr_t uart_control_0_csr;
uart_status_0_csr_t  uart_status_0_csr;
//Status flags
logic                parity_error;
logic                busy;
logic                free;

//Csr side interface
modport csr_mp(
    output uart_baud_rate_csr,
    output uart_control_0_csr,
    output uart_status_0_csr,
    input parity_error,
    input busy,
    input free
);

//UART side interface
modport uart_mp(
    input uart_baud_rate_csr,
    input uart_control_0_csr,
    input uart_status_0_csr,
    output parity_error,
    output busy,
    output free
);

endinterface: UART_csr_if