class score_board #(parameter drvrs = 4, pckg_sz = 16);
  
  checker_scoreboard_mbx i_checker_scoreboard_mbx;
  test_sb_mbx i_test_sb_mbx;
  checker_scoreboard #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaccion_entrante;
  checker_scoreboard scoreboard[$];
  checker_scoreboard auxiliar_array[$];  
  checker_scoreboard auxiliar_trans;
  shortreal retardo_promedio;
  sb_transaction orden;
  int tamano_sb = 0;
  int transacciones_completadas =0;
  int retardo_total = 0;

    task run;
    $display("[%g] El Score Board fue inicializado",$time);
    forever begin
      #5
      if(i_checker_scoreboard_mbx.num()>0)begin
        i_checker_scoreboard_mbx.get(transaccion_entrante);
        transaccion_entrante.print("Score Board: transacción recibida desde el checker");
        if(transaccion_entrante.completado) begin
          retardo_total = retardo_total + transaccion_entrante.latencia;
          transacciones_completadas++;
        end
        scoreboard.push_back(transaccion_entrante);
      end else begin
        if(i_test_sb_mbx.num()>0)begin
          i_test_sb_mbx.get(orden);
          case(orden)
            retardo_promedio: begin
              $display("Score Board: Recibida Orden Retardo_Promedio");
              retardo_promedio = retardo_total/transacciones_completadas;
              $display("[%g] Score board: el retardo promedio es: %0.3f", $time, retardo_promedio);
            end
            reporte: begin
              $display("Score Board: Recibida Orden Reporte");
              tamano_sb = this.scoreboard.size();
              for(int i=0;i<tamano_sb;i++) begin
                auxiliar_trans = scoreboard.pop_front;
                auxiliar_trans.print("SB_Report:");
                auxiliar_array.push_back(auxiliar_trans);
              end
            end
          endcase
       end
      end
    end
  endtask
  
endclass