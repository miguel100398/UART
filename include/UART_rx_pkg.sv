package UART_rx_pkg;

typedef enum logic[2:0] {
    IDLE_S      = 3'd0,
    START_S     = 3'd1,
    WAIT_BIT_S  = 3'd2, 
    SHIFT_BIT_S = 3'd3,
    DONE_S      = 3'd4
} rx_state;

endpackage: UART_rx_pkg      