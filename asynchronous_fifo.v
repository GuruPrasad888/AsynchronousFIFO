`timescale 1ns / 1ps

//  Sync FlipFlop
module sync_ff #(parameter N = 16)(
    input [N-1:0] D,
    input clk,
    input reset_n,
    output reg [N-1:0] Q
);
reg [N-1:0] q1;
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        q1 <= {N{1'b0}};
        Q <= {N{1'b0}};
    end else begin
        q1 <= D;
        Q <= q1;
    end
end
endmodule

//  Write logic to the Dual Port SRAM
module write_logic #(
    parameter word_size = 8, ptr_size = 16
    )(
    input wire [word_size-1:0] write_data_in,
    input wire [ptr_size-1:0] read_ptr,
    input wire reset_n, clk,
    output reg full,
    output reg [ptr_size-1:0] b_write_ptr,
    output reg [word_size-1:0] write_data_out,
    output wire [ptr_size-1:0] g_write_ptr
);

wire [ptr_size-1:0] next_b_write_ptr;
wire [ptr_size-1:0] next_g_write_ptr;

assign g_write_ptr = (b_write_ptr >> 1) ^ b_write_ptr;  // gray code for write pointer
assign next_b_write_ptr = b_write_ptr + 1;  // Calculate next write pointer value(binary)
assign next_g_write_ptr = (next_b_write_ptr >> 1) ^ next_b_write_ptr;   // gray code for next write pointer

always @ (posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        b_write_ptr <= 0;
        write_data_out <= {word_size{1'b0}};
        full <= 0;
    end else begin
        // Invert two MSB's of read pointer(gray code) and compare with next write pointer(gray code) value
        if (next_g_write_ptr == {~read_ptr[ptr_size-1:ptr_size-2], read_ptr[ptr_size-3:0]}) begin
            full <= 1;
        end else begin
            full <= 0;
            write_data_out <= write_data_in;
            b_write_ptr <= next_b_write_ptr;
        end
    end
end
endmodule

//  Read logic to the Dual Port SRAM
module read_logic #(
    parameter word_size = 8, ptr_size = 16
    )(
    input wire [word_size-1:0] read_data_in,
    input wire [ptr_size-1:0] write_ptr,
    input wire clk, reset_n,
    output wire [ptr_size-1:0] g_read_ptr,
    output reg [ptr_size-1:0] b_read_ptr,
    output reg [word_size-1:0] read_data_out,
    output reg empty
);

wire [ptr_size-1:0] next_b_read_ptr;

assign g_read_ptr = (b_read_ptr >> 1) ^ b_read_ptr;
assign next_b_read_ptr = b_read_ptr + 1;

always @ (posedge clk or negedge reset_n) begin
    if(~reset_n) begin
        b_read_ptr <= 0;
        read_data_out <= {word_size{1'b0}};
        empty <= 1;
    end else begin
        if (g_read_ptr == write_ptr) begin  //  Check for empty condition
            empty <= 1;
        end else begin
            empty <= 0;
            read_data_out <= read_data_in;
            b_read_ptr <= next_b_read_ptr;
        end
    end
end
endmodule

//  Dual Port SRAM with 8 bit wide and 65536 depth
module dp_sram #(
    parameter word_size = 8, depth = 65536, ptr_size = 16
    )(
    input wire [ptr_size-1:0] write_ptr,
    input wire [ptr_size-1:0] read_ptr,
    input wire [word_size-1:0] write_data_in,
    input wire write_clk, read_clk,
    output reg [word_size-1:0] read_data_out
);
reg [word_size-1:0] dp_sram [depth-1:0];

always @ (posedge write_clk) begin
    dp_sram[write_ptr] <= write_data_in;
end
always @ (posedge read_clk) begin
    read_data_out <= dp_sram[read_ptr];
end
endmodule


module asynchronous_fifo #(
    parameter word_size = 8, ptr_size = 16
    )(
    input wire [word_size-1:0] write_data_in,
    input wire write_clk, read_clk, reset_n,
    output wire [word_size-1:0] read_data_out,
    output wire full, empty
);

wire [ptr_size-1:0] sff_wl_in, sff_wl_out, sff_rl_in, sff_rl_out;
wire [ptr_size-1:0] write_ptr_sram, read_ptr_sram;
wire [word_size-1:0] write_data_to_sram, read_data_from_sram;

write_logic wl1(
    .write_data_in(write_data_in),
    .read_ptr(sff_wl_in),
    .reset_n(reset_n),
    .clk(write_clk),
    .full(full),
    .b_write_ptr(write_ptr_sram),
    .write_data_out(write_data_to_sram),
    .g_write_ptr(sff_wl_out)
);

read_logic rl1(
    .read_data_in(read_data_from_sram),
    .write_ptr(sff_rl_in),
    .clk(read_clk),
    .reset_n(reset_n),
    .g_read_ptr(sff_rl_out),
    .b_read_ptr(read_ptr_sram),
    .read_data_out(read_data_out),
    .empty(empty)
);

dp_sram dp_sram1(
    .write_ptr(write_ptr_sram),
    .read_ptr(read_ptr_sram),
    .write_data_in(write_data_to_sram),
    .write_clk(write_clk),
    .read_clk(read_clk),
    .read_data_out(read_data_from_sram)
);

sync_ff sff1(
    .D(sff_wl_out),
    .clk(read_clk),
    .reset_n(reset_n),
    .Q(sff_rl_in)
);

sync_ff sff2(
    .D(sff_rl_out),
    .clk(write_clk),
    .reset_n(reset_n),
    .Q(sff_wl_in)
);
endmodule