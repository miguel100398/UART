`timescale 1ns/1ns
module UART_tb;

    import UART_pkg::*;
    import UART_csr_pkg::*;
    logic           clk;
    logic           rst_n;
    //CSR signals
    uart_csr_addr_t csr_wr_addr;
    uart_csr_data_t csr_wr_data;
    logic           csr_wen;
    uart_csr_addr_t csr_rd_addr;
    logic           csr_ren;
    uart_csr_data_t csr_rd_data;
    //UART Internal interface
    uart_data_t     tx_data;
    logic           send;
    logic           tx_data_ready;
    uart_data_t     rx_data;
    logic           rx_data_valid;
    logic           rx_data_ready;
    //UART external interface
    logic           tx;
    logic           rx;

    //parameters to configure csr
    localparam logic [3:0] data_bits  = 8;
    localparam logic parity_bit = 1;
    localparam logic odd_parity = 1;
    localparam logic [31:0] baud_rate  = 20;

    int pass_vectors = 0;
    int fail_vectors = 0;
    int run_vectors = 0;

    //Fifo to store loopback data
    uart_data_t loop_back_data[$];

    //dut
    UART dut(
        .clk(clk),
        .rst_n(rst_n),
        .csr_wr_addr(csr_wr_addr),
        .csr_wr_data(csr_wr_data),
        .csr_wen(csr_wen),
        .csr_rd_addr(csr_rd_addr),
        .csr_ren(csr_ren),
        .csr_rd_data(csr_rd_data),
        .tx_data(tx_data),
        .send(send),
        .tx_data_ready(tx_data_ready),
        .rx_data(rx_data),
        .rx_data_valid(rx_data_valid),
        .rx_data_ready(rx_data_ready),
        .tx(tx),
        .rx(rx)
    );

    //Clock
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end


    //clocking block
    clocking cb @(posedge clk);
        output rst_n         = rst_n;
        output csr_wr_addr   = csr_wr_addr;
        output csr_wr_data   = csr_wr_data;
        output csr_wen       = csr_wen;
        output csr_rd_addr   = csr_rd_addr;
        output csr_ren       = csr_ren;
        input csr_rd_data    = csr_rd_data;
        output tx_data       = tx_data;
        output send          = send;
        input tx_data_ready  = tx_data_ready;
        input rx_data        = rx_data;
        input rx_data_valid  = rx_data_valid;
        output rx_data_ready = rx_data_ready;
        input tx             = tx;
        output rx            = rx;
    endclocking: cb

    //Write register
    task write_csr(input uart_csr_addr_t addr, input uart_csr_data_t data);
        @(cb);
        cb.csr_wr_addr  <= addr;
        cb.csr_wr_data <= data;
        cb.csr_wen      <= 1'b1;
        @(cb);
        cb.csr_wr_addr  <= 0;
        cb.csr_wr_data  <= 0;
        cb.csr_wen      <= 1'b0;
    endtask: write_csr

    //Read register
    task read_csr(input uart_csr_addr_t addr, output uart_csr_data_t data);
        @(cb);
        cb.csr_rd_addr <= addr;
        cb.csr_ren     <= 1'b1;
        @(cb);
        cb.csr_ren     <= 1'b0;
        cb.csr_rd_addr <= 0;
        data           <= cb.csr_rd_data;
    endtask: read_csr

    //Configure UART
    task configure_UART();
        @(cb);
        write_csr(UART_BAUD_RATE_CSR_ADDR, baud_rate-1);
        write_csr(UART_CONTROL_0_CSR_ADDR, {26'b0, data_bits, odd_parity, parity_bit});
        @(cb);
    endtask: configure_UART

    //Send fpga data
    task send_fpga_data(uart_data_t data);
        @(cb);
        wait (cb.tx_data_ready);
        cb.tx_data <= data;
        cb.send    <= 1'b1;
        @(cb);
        cb.tx_data <= 0;
        cb.send    <= 1'b0;
    endtask: send_fpga_data

    //Wait bit time
    task wait_bit_time();
        repeat(baud_rate) @(cb);
    endtask: wait_bit_time

    task wait_half_bit_time();
        repeat(baud_rate/2) @(cb);
    endtask: wait_half_bit_time

    //Send UART data to fgpa
    task send_uart_data(uart_data_t data);
        @(cb);
        cb.rx <= UART_START_BIT;
        wait_bit_time();
        for (int i=data_bits-1; i>=0; i--) begin
            cb.rx <= data[i];
            wait_bit_time();
        end
        if (parity_bit) begin
            if (odd_parity) begin
                cb.rx <= ~(^data);
            end else begin
                cb.rx <= (^data);
            end
            wait_bit_time();
        end
        cb.rx <= UART_STOP_BIT;
        wait_bit_time();
    endtask: send_uart_data

    //Receive data from UART
    task receive_uart_data(output uart_data_t data, output logic parity);
        wait(~cb.tx);
        data = 0;
        wait_bit_time();
        for (int i=data_bits-1; i>=0; i--) begin
            wait_half_bit_time();
            data[i] <= cb.tx;
            wait_half_bit_time();
        end 
        if (parity_bit) begin
            wait_half_bit_time();
            parity <= cb.tx;
            wait_half_bit_time();
        end
        wait_bit_time();
    endtask: receive_uart_data

    //Get data from fpga
    task get_fpga_data(output uart_data_t data);    
        @(cb);
        cb.rx_data_ready <= 1'b1;
        wait(cb.rx_data_valid);
        @(cb);
        data = cb.rx_data;
        cb.rx_data_ready <= 1'b0;
    endtask: get_fpga_data

    //Send random data continously
    task send_rand_fpga_data();
        uart_data_t data;
        fork
            begin
                forever begin
                    data = $urandom()%(2**data_bits);
                    loop_back_data.push_back(data);
                    send_fpga_data(data);
                end
            end
        join_none
    endtask: send_rand_fpga_data

    //Send data received from FPGA->UART to UART->FPGA (loopback)
    task send_loopback_uart_data();
        uart_data_t data;
        logic       parity;
        fork
            begin
                forever begin
                    receive_uart_data(data, parity);
                    check_parity(data, parity);
                    fork
                        send_uart_data(data);
                    join_none
                end
            end
        join_none
    endtask: send_loopback_uart_data

    //Test data at the end of the loopback
    task check_loopback();
        uart_data_t actual_data;
        uart_data_t exp_data;
        fork
            begin
               forever begin
                   get_fpga_data(actual_data);
                   exp_data = loop_back_data.pop_front();
                   if (actual_data == exp_data) begin
                       pass();
                   end else begin
                       $error($sformatf("Error in loopback data, expected: %0b, actual: %0b", exp_data, actual_data));
                       fail();
                   end
               end 
            end
        join_none
    endtask: check_loopback

    //Test
    task test();
        $display("Starting test");
        cb.rst_n         <= 1'b0;
        cb.rx            <= 1'b1;
        cb.send          <= 1'b0;
        cb.tx_data       <= 0;
        cb.rx_data_ready <= 1'b1;
        @(cb);
        @(cb);
        cb.rst_n <= 1'b1;
        //Configure UART
        configure_UART();
        send_rand_fpga_data();
        send_loopback_uart_data();
        check_loopback();
        repeat(10000) @(cb);
        $display("finishing test");
        if (fail_vectors != 0) begin
            $fatal($sformatf("Test fail, num_errors: %0d, num_pass: %0d, num_vectos: %0d", fail_vectors, pass_vectors, run_vectors));
        end else begin
            $display($sformatf("Test pass: num_erros: %0d, num_pass: %0d, num_vectors: %0d", fail_vectors, pass_vectors, run_vectors));
        end
    endtask: test

    initial begin
       test();
       $finish(); 
    end

    function void check_parity(uart_data_t data, logic parity);
        if (parity_bit) begin
           if(odd_parity) begin
               if (parity == ~(^data)) begin
                   pass();
               end else begin
                   $error($sformatf("Error in odd parity bit, data: %0b, exp_parity: %0b, parity: %0b", data, ~(^data), parity));
                   fail();
               end
           end else begin
               if (parity == (^data)) begin
                   pass();
               end else begin
                   $error($sformatf("Error in even parity bit, data: %0b, exp_parity: %0b, parity: %0b", data, ^data, parity));
                   fail();
               end
           end
        end
    endfunction: check_parity

    function void pass();
        pass_vectors++;
        run_vectors++;
    endfunction: pass

    function void fail();
        fail_vectors++;
        run_vectors++;
    endfunction: fail

endmodule: UART_tb