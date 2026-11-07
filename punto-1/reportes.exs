defmodule Reportes do
  @moduledoc """
  modulo para generar el reporte de sismos y los registros rechazados
  """

  # filtra los movimientos que no tienen una ciudad valida en el catalogo
  def filtrar_movimientos_huerfanos(movimientos, ciudades) do
    ids_validos = MapSet.new(Enum.map(ciudades, fn c -> c.id_ciudad end))

    Enum.reduce(movimientos, {[], 0}, fn mov, {acc_validos, rech_count} ->
      if MapSet.member?(ids_validos, mov.id_ciudad) do
        {[mov | acc_validos], rech_count}
      else
        {acc_validos, rech_count + 1}
      end
    end)
    |> then(fn {validos_inv, rech_count} -> {Enum.reverse(validos_inv), rech_count} end)
  end

  # procesa la ciudad llamando a la funcion recursiva
  def procesar_ciudad(ciudad, movimientos) do
    movimientos_ciudad = Enum.filter(movimientos, fn m -> m.id_ciudad == ciudad.id_ciudad end)
    procesar_movimientos_recursivo(movimientos_ciudad, 0, nil, 0.0)
  end

  # caso base cuando la ciudad no tiene sismos
  defp procesar_movimientos_recursivo([], 0, _max_mov, _suma_prof) do
    {0, "No aplica", "No aplica"}
  end

  # caso base al terminar de recorrer la lista para sacar el promedio
  defp procesar_movimientos_recursivo([], cantidad, max_mov, suma_prof) do
    promedio = Float.round(suma_prof / cantidad, 2)
    promedio_str = :io_lib.format("~.2f km", [promedio]) |> List.to_string()
    max_str = "#{max_mov.codigo}-#{max_mov.magnitud}"
    {cantidad, max_str, promedio_str}
  end

  # caso recursivo para acumular datos del reporte
  defp procesar_movimientos_recursivo([mov | resto], cantidad, max_mov, suma_prof) do
    nuevo_max =
      case max_mov do
        nil -> mov
        actual -> if mov.magnitud > actual.magnitud, do: mov, else: actual
      end

    procesar_movimientos_recursivo(resto, cantidad + 1, nuevo_max, suma_prof + mov.profundidad)
  end

  # arma el texto general del reporte para consola y archivo
  def generar_reporte(ciudades, movimientos, rech_ciudades, rech_movimientos) do
    reporte_ciudades =
      Enum.map(ciudades, fn ciudad ->
        movs_ciudad = Enum.filter(movimientos, fn m -> m.id_ciudad == ciudad.id_ciudad end)
        {cantidad, max_info, prof_promedio} = procesar_ciudad(ciudad, movimientos)

        detalle_movs =
          if cantidad == 0 do
            "  Sin movimientos registrados"
          else
            Enum.map_join(movs_ciudad, "\n", fn m ->
              "  - #{m.codigo} | #{m.hora_inicio} | #{m.hora_final} | Magnitud: #{m.magnitud} | Profundidad: #{m.profundidad} km"
            end)
          end

        """
        Ciudad: #{ciudad.nombre} (#{ciudad.numero_habitantes} habitantes)
        Movimientos:
        #{detalle_movs}
        Total de movimientos: #{cantidad}
        Movimiento de mayor magnitud: #{max_info}
        Profundidad promedio: #{prof_promedio}
        """
      end)

    auditoria = """
    Registros rechazados por archivo:
    Ciudades: #{rech_ciudades}
    Movimientos: #{rech_movimientos}
    """

    Enum.join(reporte_ciudades, "\n") <> "\n" <> auditoria
  end
end
