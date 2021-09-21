# Proyecto-1-verificacion

#Link del git

https://github.com/RDCerdas/Proyecto-1-verificacion

#Ejecución de las pruebas

Se incluyen dos formas de correr la prueba. El primero es utilizando ***comando.sh*** y lo que hace es unicamente cargar las herramientas del servidor, compilar utilizando vcs y correr el ejecutable que genera.

La segunda es utilizando ***comando_corridas.sh*** Este lo que hace es generar diferentes pruebas variando los parámetros en función de los for que contiene, además, realiza la gráfica del ancho de banda máximo y mínimo de las pruebas.


#Resultados

Se incluye un log de las pruebas corridas en serie llamado log_run, además, se incluye el reporte generado de la última prueba realizada llamado report.csv. Los datos para graficar son incluidos en archivos llamados max_bandwidth.csv y min_bandwidth.csv. Finalmente, se incluyen dos imagenes con ejemplos de lo gráficado utilizando gnuplot. Se llaman min_bandwith.png y max_bandwidth.png respectivamente.

Si se quieren graficar los datos de ancho de banda se puede utilizar ***gnuplot -p min.gnuplot*** y ***gnuplot -p max.gnuplot***
