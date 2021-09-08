class ambiente #(parameter drvrs = 4, pckg_sz = 16, bits = 0, fifo_depth = 16);
     virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) _if;

     driver #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits), .fifo_depth(fifo_depth)) driver_inst;
     agent #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agent_inst;

     agent_driver_mbx agent_driver_mbx_inst;
     driver_checker_mbx driver_checker_mbx_inst;
     monitor_checker_mbx monitor_checker_mbx_inst;
     checker_scoreboard_mbx checker_scoreboard_mbx_inst;
     test_agent_mbx test_agent_mbx_inst;

  function new(test_agent_mbx t_a_mbx);
      // Instanciación de los mailboxes
      agent_driver_mbx_inst = new;
      driver_checker_mbx_inst = new;
      monitor_checker_mbx_inst = new;
      checker_scoreboard_mbx_inst = new;
       
      // Instanciación de los componentes
      driver_inst = new();
      agent_inst = new();

      // Conexion de las interfaces y los mailboces
      driver_inst.vif = _if;
      driver_inst.i_agent_driver_mbx = agent_driver_mbx_inst;
      driver_inst.i_driver_checker_mbx = driver_checker_mbx_inst;
      agent_inst.i_test_agent_mbx = t_a_mbx;
    	agent_inst.i_agent_driver_mbx = agent_driver_mbx_inst;
       
       	

     endfunction

     virtual task run();
        $display("[%g]  El ambiente fue inicializado",$time);
        fork
            driver_inst.run();
            agent_inst.run();
        join_none
     endtask
endclass