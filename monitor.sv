class monitor#(parameter drvrs = 4, pckg_sz = 16, bits = 0, fifo_depth = 16);
    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) vif;
    monitor_checker_mbx i_monitor_checker_mbx;
    bit push [drvrs];
    bit [pckg_sz-1:0] D_push [drvrs];
    bit valid;

    function new();
        foreach(this.push[i]) begin
            this.push[i] = 0;
            this.D_push[i] = 0;
        end
    endfunction //new()

    task run();
        $display("[%g]  El monitor fue inicializado",$time);
        @(posedge vif.clk);

        forever begin
            foreach(this.push[i]) begin
                this.push[i] = vif.push[0][i];
                this.D_push[i] = vif.D_push[0][i];
            end

            foreach(this.push[i]) if(this.push[i]) valid = 1;

            if (valid) begin
                monitor_checker #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaction;
                transaction = new();
                foreach(this.push[i]) begin
                    transaction.valid[i] = this.push[i];
                    transaction.dato[i] = this.D_push[i];
                end
                transaction.tiempo_lectura = $time();
                transaction.print("Monitor: Transaccion enviada");
                i_monitor_checker_mbx.put(transaction);
            end

            valid = 0;
            @(posedge vif.clk);
        end

    endtask //runs 
endclass//monitor