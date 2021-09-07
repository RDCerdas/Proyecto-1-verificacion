//////////////////////////////////////////////////////////////
// Definición del tipo de transacciones posibles en la fifo //
//////////////////////////////////////////////////////////////

// Tipos de operaciones
typedef enum {escritura, reset} tipo_trans; 
// Tipos de secuencias
typedef enum {trans_aleatoria, trans_especifica, sec_trans_aleatorias, sec_trans_especificas, sec_escrituras_aleatorias, sec_escrituras_especificas} tipo_sec;


// Definicion de los paquetes
// Paquete agente-driver, driver-checker
class trans_bus #(parameter pckg_sz = 16, drvrs = 4);
    rand int retardo;
    rand bit[pckg_sz-9:0] dato [drvrs-1:0];
    rand bit[7:0] device_dest;
    rand bit escribir [drvrs-1:0];
    bit overflow [drvrs-1:0];
    bit reset;
    int tiempo_escritura;
    int max_retardo;

    constraint const_escribir {escribir > 0; escribir < drvrs}

    constraint const_retardo {retardo <= max_retardo; retardo>= 0;}

    function new(int ret, bit [pckg_sz-1:0] dto = 0, bit[pckg_sz-1:0] dto [drvrs-1] = 0, bit escribir [drvrs-1:0] = 0, bit rst = 0, int max_retardo = 5);
      this.retardo = ret;
      for(int i = 0; i<drvrs; i++) begin
          this.overflow[i] = 0
      end
      this.reset = rst;
      this.tiempo_escritura = 0;
      this.max_retardo = 5;
    endfunction

    function clean();
      this.retardo = 0;
      for(int i = 0; i<drvrs; i++) begin
          this.dato[i] = 0; 
          this.escribir[i] = 0;
          this.overflow[i] = 0
      end
      this.reset = 0;
      this.tiempo_escritura = 0;
    endfunction

    function print;
      $display("[%g] %s Tiempo=%g Reset=%g Retardo=%g Dato=%p Escritura=%p Overflow=%p",$time,tag,tiempo,this.reset, this.retardo, this.dato, this.escribir, this.overflow);
      
    endfunction
endclass


// Interfaz para conectar con el bus
interface bus_if #(parameter drvrs = 4, pckg_sz = 16, bits = 0) (input clk);
    logic reset;
    logic pndng[bits-1:0][drvrs-1:0];
    logic push[bits-1:0]drvrs-1:0];
    logic pop[bits-1:0]drvrs-1:0];
    logic [pkg_sz-1:0] D_pop [bits-1:0]drvrs-1:0];
    logic [pkg_sz-1:0] D_push [bits-1:0]drvrs-1:0];
endinterface //bus_if 



// Paquete monitor-checker
class monitor_checker (#parameter pckg_sz = 16, drvrs = 4);
    bit [pckg_sz-9:0] dato [drvrs-1:0];
    bit valid [drvrs-1:0];
    int tiempo_lectura;

    function new();
        for(int i = 0; i<drvrs; i++) begin
          this.dato[i] = 0; 
          this.valid[i] = 0;
        this.tiempo_lectura = 0;
    endfunction 
endclass

// Definicion del paquete entre checker y scoreboard
class checker_scoreboard #parameter pckg_sz = 16, drvrs = 4);
    int tiempo_escritura;
    int tiempo_lectura;
    int latencia;
    int device_dest;
    int device_env;
    bit [pckg_sz-1:0] dato;
    tipo_trans tipo;

    function new(bit [pckg_sz-1:0] dto = 0, int t_escritura = 0, int t_lectura = 0, int lat = 0, int dev_env = 0, int dev_dest = 0, tipo_trans tp = reset);
      this.dato = dto;
      this.tiempo_escritura = t_escritura;
      this.tiempo_lectura = t_lectura;
      this.latencia = lat;
      this.device_env = dev_env;
      this.device_dest = dev;
      this.tipo = tp;
      
    endfunction

    function clean();
      this.dato = 0;
      this.tiempo_escritura = 0;
      this.tiempo_lectura = 0;
      this.latencia = 0;
      this.device_dest = 0;
      this.device_env = 0;
      this.tipo = 0;
    endfunction
endclass

class test_agent #(parameter pckg_sz = 16, drvrs = 4);
    tipo_sec  tipo_secuencia;
    bit [pckg_sz-9:0] dato
    int retardo;
    int spec_device_env;
    int spec_device_dest;

    function new(tipo_sec t_sec = trans_aleatoria, int dato = 0, int ret = 0, int dev_env = 0, int dev_dest = 0);
      this.tipo_secuencia = t_sec;
      this.spec_dato = dato;
      this.retardo = ret;
      this.spec_dev_env = dev_env;
      this.spec_dev_dest = dev.dest;
      
    endfunction


endclass


// Definicion de las mailboxes

// Mailbox entre agente y driver
typedef mailbox #(trans_bus) agent_driver_mbx;

// Mailbox entre driver y checker
typedef mailbox #(trans_bus) driver_checker_mbx;

// Mailbox entre monitor y checker
typedef mailbox #(monitor_checker) monitor_checker_mbx;

// Mailbow entre checker y scoreboard
typedef mailbox #(checker_scoreboard) checker_scoreboard_mbx;

// Mailbox entre agente y test
typedef mailbox #(test_agent) test_agent_mbx;