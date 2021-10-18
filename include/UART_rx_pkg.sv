package UART_rx_pkg;

typedef enum logic[1:0] {
    IDLE_S      = 2'd0,
    WAIT_BIT_S  = 2'd1, 
    SHIFT_BIT_S = 2'd2,
    DONE_S      = 2'd3
} rx_state;

endpackage: UART_rx_pkg      