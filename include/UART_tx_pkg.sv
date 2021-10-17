package UART_tx_pkg;

typedef enum logic[1:0] {
    IDLE_S      = 2'd0,
    START_S     = 2'd1,
    WAIT_BIT_S  = 2'd2, 
    SHIFT_BIT_S = 2'd3
} tx_state;

endpackage: UART_tx_pkg      