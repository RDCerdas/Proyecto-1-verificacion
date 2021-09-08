`timescale 1ns/1ps

//`include "Library.sv"
`include "interface_transactions.sv"
`include "driver.sv"
`include "agent.sv"
`include "ambiente.sv"
`include "test.sv"

module test_bench;
    reg clk;
    parameter pckg_sz = 16;
    parameter drvrs = 4;
    parameter bits = 0;
    parameter fifo_depth = 16;
    parameter broadcast = {8{1'b1}};

    test #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits), .fifo_depth(fifo_depth)) t0;
    bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) _if(.clk(clk));

    always #5 clk = ~clk;
        
    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) uut(
        .clk(_if.clk),
        .reset(_if.reset),
        .pndng(_if.pndng),
        .push(_if.push),
        .pop(_if.pop),
        .D_pop(_if.D_pop),
        .D_push(_if.D_push)
    );

    initial begin
        clk = 0;
        t0 = new();
        t0._if = _if;
      	t0.ambiente_inst.driver_inst.vif = _if;
        fork
            t0.run();
        join_none
    end

    always@(posedge clk) begin
        if ($time > 100000)begin
            $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
            $finish;
    end
  end

endmodule