Code.require_file("estructuras.exs")
Code.require_file("txt.exs")
Code.require_file("persistencia.exs")
Code.require_file("reportes.exs")

defmodule Coordinador do
  @moduledoc """
  modulo coordinador para ejecutar los procesos concurrentes de lectura y armar el reporte
  """

  @ruta_ciudades "resources/ciudades.txt"
  @ruta_movimientos "resources/movimientos.txt"

  # funcion principal para iniciar la lectura paralela con spawn
  def generar_reporte_local do
    coordinador = self()

    # proceso trabajador para leer ciudades
    spawn(fn ->
      resultado = Txt.leer_txt(@ruta_ciudades, &Ciudad.parsear_linea/1)
      send(coordinador, {:ciudades, resultado})
    end)

    # proceso trabajador para leer movimientos
    spawn(fn ->
      resultado = Txt.leer_txt(@ruta_movimientos, &Movimiento.parsear_linea/1)
      send(coordinador, {:movimientos, resultado})
    end)

    # espera los mensajes de los trabajadores
    esperar_respuestas(nil, nil)
  end

  # recibe las respuestas de los procesos sin importar el orden
  defp esperar_respuestas(res_ciudades, res_movimientos) do
    receive do
      {:ciudades, res} ->
        if res_movimientos != nil do
          procesar_resultados(res, res_movimientos)
        else
          esperar_respuestas(res, res_movimientos)
        end

      {:movimientos, res} ->
        if res_ciudades != nil do
          procesar_resultados(res_ciudades, res)
        else
          esperar_respuestas(res_ciudades, res)
        end
    end
  end

  # si ambos leyeron bien genera el reporte, lo imprime y lo guarda
  defp procesar_resultados({ciudades, rech_c}, {movimientos, rech_m})
       when is_list(ciudades) and is_list(movimientos) do

    {movimientos_validos, huerfanos_rechazados} =
      Reportes.filtrar_movimientos_huerfanos(movimientos, ciudades)

    total_rechazados_movimientos = rech_m + huerfanos_rechazados

    reporte_texto =
      Reportes.generar_reporte(
        ciudades,
        movimientos_validos,
        rech_c,
        total_rechazados_movimientos
      )

    Util.mostrar_mensaje(reporte_texto)
    Persistencia.guardar_reporte(reporte_texto)
  end

  # si falla el archivo de ciudades
  defp procesar_resultados({:error, ruta}, _movs) do
    Util.mostrar_error("No se pudo leer el archivo '#{ruta}'. Se conserva el reporte anterior.")
  end

  # si falla el archivo de movimientos
  defp procesar_resultados(_ciuds, {:error, ruta}) do
    Util.mostrar_error("No se pudo leer el archivo '#{ruta}'. Se conserva el reporte anterior.")
  end
end

Coordinador.generar_reporte_local()
