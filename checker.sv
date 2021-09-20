class arreglo #(parameter pckg_sz = 16);
  bit [pckg_sz-1:0] Dato ;
  bit [8:0] enviado;
  int tiempo_lectura;
      function new();
        this.tiempo_lectura=0;
        this.Dato = 0; 
        this.enviado=0;
    endfunction 

    function print(string tag);
	$display("[%g] %s  Tiempo Lectura = %g Enviado = %g Dato = %h", $time, tag, this.tiempo_lectura, this.enviado, this.Dato);
    endfunction

endclass 

class checkers #(parameter drvrs = 4,  pckg_sz = 16);
  trans_bus #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaction_driver;
  monitor_checker #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaction_monitor;
  checker_scoreboard #(.pckg_sz(pckg_sz), .drvrs(drvrs)) to_sb;
  monitor_checker_mbx i_monitor_checker_mbx;
  driver_checker_mbx i_driver_checker_mbx;
  checker_scoreboard_mbx i_checker_scoreboard_mbx;
  arreglo auxiliar;
  arreglo temp;
  arreglo cola[$];
  int latencia;
  int tamano;
  bit [pckg_sz-1:0] Dato;
  bit [8:0] destino;
  int timeout = 5000;
  
  function new();
   this.cola = {};
    this.temp=new;
    this.auxiliar=new;
  endfunction 
  
  
  task run;
   $display("[%g]  El checker fue inicializado",$time);
   forever begin
	   #5;
	   
	if(i_monitor_checker_mbx.try_get(transaction_monitor)) begin
       foreach (transaction_monitor.valid[i]) begin
         if (transaction_monitor.valid[i]==1) begin
           Dato=transaction_monitor.dato[i];
           tamano=0;
           foreach (cola[a]) begin

		  if (Dato==cola[a].Dato) begin

		   to_sb = new();
           	   latencia = transaction_monitor.tiempo_escritura - cola[a].tiempo_lectura;
           	   to_sb.dato=Dato;
           	   to_sb.tiempo_escritura=transaction_monitor.tiempo_escritura;
               to_sb.device_dest=transaction_monitor.dato[i] [pckg_sz-1:pckg_sz-8];
           	   to_sb.latencia=latencia;
           	   to_sb.tiempo_lectura=cola[a].tiempo_lectura;
           	   to_sb.completado = 1;
           	   to_sb.valido=1;
		   to_sb.reset = 0;
           	   to_sb.device_env=cola[a].enviado;
           	   to_sb.print("Checker:Transaccion Completada");
           	   i_checker_scoreboard_mbx.put(to_sb);
           	   tamano=1;
		   cola.delete(a);
		   break;
             end
           end
           if (tamano==0) begin
           	 transaction_monitor.print("Checker: El dato recibido por el monitor no fue enviado por el driver");
         	   $finish;
           end
   	end
         end
       end
       if(i_driver_checker_mbx.try_get(transaction_driver))begin
     transaction_driver.print("Checker: Se recibe trasacción desde el driver");
     foreach (transaction_driver.escribir[i]) begin
       if (transaction_driver.escribir[i]==1) begin
         if (transaction_driver.device_dest[i]==8'hFF) begin
           for (int f=0; f<(drvrs-1); f++) begin
              temp = new();
              temp.enviado=i;
              temp.Dato[pckg_sz-9:0]=transaction_driver.dato[i];
              temp.Dato[pckg_sz-1:pckg_sz-8]=transaction_driver.device_dest[i];
              temp.tiempo_lectura=transaction_driver.tiempo_lectura;
              cola.push_back(temp);
           end
          end else begin
            temp = new();
            temp.enviado=i;
            temp.Dato[pckg_sz-9:0]=transaction_driver.dato[i];
            temp.Dato[pckg_sz-1:pckg_sz-8]=transaction_driver.device_dest[i];
            temp.tiempo_lectura=transaction_driver.tiempo_lectura;
            cola.push_back(temp);
          end
        end
      end
      if (transaction_driver.reset==1) begin
        while(cola.size()>0) begin
          auxiliar=cola.pop_back;
          to_sb = new();
          to_sb.dato=auxiliar.Dato[pckg_sz-9:0];
          to_sb.tiempo_escritura=0;
          to_sb.device_dest=auxiliar.Dato[pckg_sz-1:pckg_sz-8];
          to_sb.latencia=0;
          to_sb.tiempo_lectura=auxiliar.tiempo_lectura;
          to_sb.completado = 0;
          to_sb.valido=0;
          to_sb.reset = 1;
          to_sb.device_env=auxiliar.enviado;
          to_sb.print("Checker:Transaccion Completada");
          i_checker_scoreboard_mbx.put(to_sb);
          $display("Dato_abortado= %h, Dispositivo_que_envia = %h, Dispositivo que recibe= %h",auxiliar.Dato[pckg_sz-9:0],auxiliar.enviado,auxiliar.Dato[pckg_sz-1:pckg_sz-8]);
        end
      end
	  end

    foreach (cola[a]) begin
	    if(cola[a].tiempo_lectura+timeout < $time) begin
        cola[a].print("Checker: Error timeout de dato");
        $finish;
end
    end
  end
     endtask 
endclass 
