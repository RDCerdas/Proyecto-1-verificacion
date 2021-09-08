class test #(parameter drvrs = 4, pckg_sz = 16, bits = 0, fifo_depth = 16);
    test_agent_mbx test_agent_mbx_inst;
    parameter num_transacciones = 10;
    parameter max_retardo = 4;
    test_agent #(.pckg_sz(pckg_sz), .drvrs(drvrs)) instruccion;
    
    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) _if;

    ambiente #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits), .fifo_depth(fifo_depth)) ambiente_inst;

    function new();
        test_agent_mbx_inst = new();
        ambiente_inst = new(test_agent_mbx_inst);
        ambiente_inst._if = _if;
        ambiente_inst.agent_inst.num_transacciones = num_transacciones;
        ambiente_inst.agent_inst.max_retardo = max_retardo;

    endfunction //new()

    task run;
        $display("[%g]  El Test fue inicializado",$time);
        fork
            ambiente_inst.run();
        join_none

        instruccion = new();
        instruccion.tipo_secuencia = sec_trans_aleatorias;
      test_agent_mbx_inst.put(instruccion);
      $display("[%g]  Test: Enviada primera instruccion al agente transacciones_aleatorias",$time);

    endtask

endclass //test 