// Clase para emular los diferentes fifos de cada dispositivo
class driver_fifo #(parameter pckg_sz = 16, fifo_depth = 16);
    bit pop;
    bit pndng;
    bit overflow;
    bit [pckg_sz-1:0] emul_fifo [$];
    int identification;


    function new(int ident);
        this.pop = 0;
        this.pndng = 0;
        this.overflow = 0;
        this.identification = ident;

    endfunction //new()

    function bit [pckg_sz-1:0] update();
    	this.overflow = 0;
        if(pop) begin
            if(emul_fifo.size()==0) begin
              $warning("[$g] Underflow in device %d fifo happened", $time, this.identification);
            end else if (emul_fifo.size()==fifo_depth) begin
                this.overflow = 1;
              $warning("[$g] Overflow in device %d fifo happened", $time, this.identification);
            end else
                return emul_fifo.pop_front();
                if((emul_fifo.size()==0)) pndng = 0;
        end
        if(emul_fifo.size()==0)
            return 0;
        else
            return emul_fifo[0];
    endfunction

    function void write(bit [pckg_sz-1:0] dato, bit escribir);
      if (escribir) begin
        emul_fifo.push_back(dato);
        pndng = 1;
      end
    endfunction

endclass //driver_fifo

// Driver
class driver #(parameter drvrs = 4, pckg_sz = 16, bits = 0, fifo_depth = 16);
    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) vif;
    driver_fifo #(.pckg_sz(pckg_sz), .fifo_depth(fifo_depth)) drivers_fifo  [drvrs];
    agent_driver_mbx i_agent_driver_mbx;
    driver_checker_mbx i_driver_checker_mbx;
  	int espera;

    task run();
      $display("[%g]  El driver fue inicializado",$time);
      foreach (drivers_fifo[i]) begin
        drivers_fifo[i] = new(i);
      end
      @(posedge vif.clk);
      vif.reset=1;
      @(posedge vif.clk);

      forever begin
        trans_bus #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaction; 
        vif.reset = 0;
        $display("[%g] El Driver espera por una transacción",$time);
        espera = 0;
        @(posedge vif.clk);
        i_agent_driver_mbx.get(transaction);
        transaction.print("Driver: Transaccion recibida");
        $display("Transacciones pendientes en el mbx agnt_drv = %g",i_agent_driver_mbx.num());

        while(espera < transaction.retardo)begin
          @(posedge vif.clk);
          espera = espera+1;
	    end

        if(transaction.reset) begin
            vif.reset = 1;
        end

        // Se actualiza las señales de entrada y salida de primero
        foreach (drivers_fifo[i]) begin 
          drivers_fifo[i].pop = vif.pop[0][i];
          vif.D_pop[0][i] = drivers_fifo[i].update();
            drivers_fifo[i].write({transaction.device_dest[i], transaction.dato[i]}, transaction.escribir[i]);
        end
      end
    endtask
endclass //driver #parameter(parameter drvrs = 4, pckg_sz = 16, bits = 0)