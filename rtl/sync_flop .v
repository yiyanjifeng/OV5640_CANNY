module sync_flop (
    input wire clk,
    input wire async_signal,
    output reg sync_signal
);
    reg sync1, sync2;

    always @(posedge clk) begin
        sync1 <= async_signal;
        sync2 <= sync1;
        sync_signal <= sync2;
    end
endmodule