`timescale 1ns / 1ps

module tb_asynchronous_fifo;
reg [7:0] write_data_in;
reg write_clk;
reg read_clk;
reg reset_n;
wire [7:0] read_data_out;
wire full;
wire empty;

always #5 write_clk = ~write_clk;
always #4 read_clk = ~read_clk;

asynchronous_fifo DUT(
    .write_data_in(write_data_in),
    .write_clk(write_clk),
    .read_clk(read_clk),
    .reset_n(reset_n),
    .read_data_out(read_data_out),
    .wire(wire),
    .empty(empty)
);

initial begin

`timescale 1ns / 1ps

module tb_asynchronous_fifo;

reg [7:0] write_data_in;
reg write_clk;
reg read_clk;
reg reset_n;
wire [7:0] read_data_out;
wire full;
wire empty;

always #5 write_clk = ~write_clk;  // Write clock (10 ns period)
always #4 read_clk = ~read_clk;    // Read clock (8 ns period)

// Instantiate the FIFO
asynchronous_fifo DUT(
    .write_data_in(write_data_in),
    .write_clk(write_clk),
    .read_clk(read_clk),
    .reset_n(reset_n),
    .read_data_out(read_data_out),
    .full(full),
    .empty(empty)
);

// Counters for simulation
integer write_cnt = 0;
integer read_cnt = 0;

initial begin
    // Initialize signals
    write_clk = 0;
    read_clk = 0;
    write_data_in = 8'd0;
    reset_n = 0;

    // Apply reset
    #20;
    reset_n = 1;
    #10;

    // Write values to FIFO
    fork
        begin : WRITE_PROC
            while (write_cnt < 20) begin
                @(posedge write_clk);
                if (!full) begin
                    write_data_in <= write_cnt;
                    write_cnt = write_cnt + 1;
                end
            end
        end

        begin : READ_PROC
            // Start reading a bit later to allow FIFO to fill up
            #100;
            while (read_cnt < 20) begin
                @(posedge read_clk);
                if (!empty) begin
                    read_cnt = read_cnt + 1;
                end
            end
        end
    join

    #50;
    $finish;
end

endmodule
