class test #(parameter drvrs = 4, pckg_sz = 16, bits = 0, fifo_depth = 16);
    test_agent_mbx test_agent_mbx_inst;
    test_sb_mbx test_sb_mbx_inst;
    parameter num_transacciones = 25;
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
      	instruccion.num_transacciones = 100;
      	instruccion.max_retardo = 15;
        instruccion.tipo_secuencia = sec_trans_aleatorias;
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada primera instruccion al agente transacciones_aleatorias",$time);

        instruccion = new();
        instruccion.num_transacciones = 5;
      	instruccion.retardo = 10;
        instruccion.tipo_secuencia = sec_trans_especifica;
        instruccion.enviar_dato_especifico(0, 'hAA, 'hff); //Se envía dato 0x10 desde dispositivo 0 a 2
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada segunda instruccion al agente broadcast 1 dispositivo",$time);

        instruccion = new();
        instruccion.num_transacciones = 5;
      	instruccion.retardo = 10;
        instruccion.tipo_secuencia = sec_trans_especifica;
        for(int i; i < drvrs; i++) begin
          instruccion.enviar_dato_especifico(i, 'hFF, 'hff); //Se envía dato 0x10 desde dispositivo 0 a 2
        end
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada tercera instruccion al agente broadcast en todos los canales",$time);

        instruccion = new();
      	instruccion.retardo = 10;
        instruccion.tipo_secuencia = trans_especifica;
        for(int i; i < drvrs; i++) begin
          instruccion.enviar_dato_especifico(i, 'h00, 'hff); //Se envía dato 0x10 desde dispositivo 0 a 2
        end
        instruccion.reset = 1;
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada cuarta instruccion al agente broadcast en todos con reset",$time);

        instruccion = new();
      	instruccion.retardo = 10;
        instruccion.tipo_secuencia = trans_especifica;
        instruccion.enviar_dato_especifico(0, 'h11, drvrs-1); //Se envía dato 0x10 desde dispositivo 0 a dispositivo drvrs-1
        instruccion.reset = 1;
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada quinta instruccion al agente broadcast 1 dispositivo con reset",$time);

        instruccion = new();
      	instruccion.retardo = 10;
        instruccion.tipo_secuencia = trans_especifica;
        for(int i; i < drvrs; i++) begin
          if(i==0) instruccion.enviar_dato_especifico(i, 'h33, drvrs-1); //Se envía dato 0x10 desde dispositivo 0 a 2
          else instruccion.enviar_dato_especifico(i, 'h00, 'h00); //Se envía dato 0x10 desde dispositivo 0 a 2
        end
        instruccion.reset = 1;
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada sexta instruccion al agente reset con escritura en todos",$time);

  // Finaliza primer seccion de pruebas
	#2000000;

	test_sb_mbx_inst.put(reset_ancho_banda);


        instruccion = new();
        instruccion.num_transacciones = 300;
      	instruccion.max_retardo = 1;
        instruccion.tipo_secuencia = sec_escrituras_aleatorias;
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada quinta instruccion al agente 300 escrituras en todos los canales",$time);

	#2000000;

	test_sb_mbx_inst.put(append_csv_max_bw);
		

	test_sb_mbx_inst.put(reset_ancho_banda);

        instruccion = new();
        instruccion.num_transacciones = 300;
      	instruccion.max_retardo = 1;
        instruccion.tipo_secuencia = sec_trans_especificas;
        instruccion.enviar_dato_especifico(0, 'h00, drvrs-1); //Se envía dato 0xFF desde dispositivo 1 a 4
        test_agent_mbx_inst.put(instruccion);
        $display("[%g]  Test: Enviada sexta 300 escrituras en un canal",$time);


	#2000000;

	test_sb_mbx_inst.put(append_csv_min_bw);
	test_sb_mbx_inst.put(report_csv);

	#100;
       
	$finish();
    endtask

endclass //test 
