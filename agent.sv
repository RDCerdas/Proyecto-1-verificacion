class agent #(parameter pckg_sz = 16, drvrs = 4);
  agent_driver_mbx i_agent_driver_mbx;           // Mailbox del agente al driver
  test_agent_mbx i_test_agent_mbx;
  int num_transacciones;                 // Número de transacciones para las funciones del agente
  int max_retardo; 
  test_agent #(.pckg_sz(pckg_sz), .drvrs(drvrs)) instruccion;      // para guardar la última instruccion leída
  trans_bus #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaccion;
   
  function new();
    num_transacciones = 6;
    max_retardo = 5;
  endfunction

  task run;
    $display("[%g]  El Agente fue inicializado",$time);
    forever begin
      #1
      if(i_test_agent_mbx.num() > 0)begin
        $display("[%g]  Agente: se recibe instruccion",$time);
        i_test_agent_mbx.get(instruccion);
        this.num_transacciones = instruccion.num_transacciones;
        this.max_retardo = instruccion.max_retardo;

        case(instruccion.tipo_secuencia)
          sec_trans_aleatorias: begin // Esta instrucción genera una secuencia de instrucciones aleatorias
            for(int i=0; i<num_transacciones;i++) begin
              transaccion = new();
              transaccion.max_retardo = this.max_retardo;
              transaccion.randomize();
              transaccion.print("Agente: transacción creada");
              i_agent_driver_mbx.put(transaccion);
            end
          end
        endcase
      end
    end
  endtask
endclass
