class test #(parameter drvrs = 4, pckg_sz = 16, bits = 0, fifo_depth = 16);
    test_agent_mbx test_agent_mbx_inst;
    test_sb_mbx test_sb_mbx_inst;
    parameter num_transacciones = 4;
    parameter max_retardo = 7;
    test_agent #(.pckg_sz(pckg_sz), .drvrs(drvrs)) instruccion;
    
    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) _if;

    ambiente #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits), .fifo_depth(fifo_depth)) ambiente_inst;

    function new();
        test_agent_mbx_inst = new();
        test_sb_mbx_inst = new();
        ambiente_inst = new(test_agent_mbx_inst, test_sb_mbx_inst);
        ambiente_inst._if = _if;


    endfunction //new()

    task run;
        $display("[%g]  El Test fue inicializado",$time);
        fork
            ambiente_inst.run();
        join_none

        instruccion = new();
      	instruccion.num_transacciones = num_transacciones;
      	instruccion.max_retardo = max_retardo;
        instruccion.tipo_secuencia = sec_trans_aleatorias;
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada primera instruccion al agente transacciones_aleatorias",$time);

        instruccion = new();
        instruccion.num_transacciones = num_transacciones;
      	instruccion.max_retardo = max_retardo;
        instruccion.tipo_secuencia = trans_especifica;
        instruccion.enviar_dato_especifico(0, 'h10, 'h2); //Se envía dato 0x10 desde dispositivo 0 a 2
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada segunda instruccion al agente transaccion_especifica",$time);

        instruccion = new();
        instruccion.num_transacciones = num_transacciones;
      	instruccion.max_retardo = max_retardo;
        instruccion.tipo_secuencia = sec_trans_especificas;
        instruccion.enviar_dato_especifico(1, 'hFF, 'h4); //Se envía dato 0xFF desde dispositivo 1 a 4
        instruccion.enviar_dato_especifico(2, 'h00, 'h1); //Se envía dato 0x00 desde dispositivo 2 a 1
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada tercera instruccion al agente transacciones_especificas",$time);


        instruccion = new();
        instruccion.num_transacciones = num_transacciones;
      	instruccion.max_retardo = max_retardo;
        instruccion.tipo_secuencia = sec_escrituras_aleatorias;
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada cuarta instruccion al agente escrituras_aleatorias",$time);

    endtask

endclass //test 