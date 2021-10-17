//Description: UART package, defines common types and parameters used by UART
//Author: Miguel Bucio miguel_angel_bucio@hotmail.com
//Date: 4/10/2021
//Parameters:


package UART_pkg;

import UART_csr_pkg::*;

parameter logic UART_START_BIT = 1'b0;
parameter logic UART_STOP_BIT  = 1'b1; 

typedef logic[7:0] uart_data_t;

endpackage: UART_pkg