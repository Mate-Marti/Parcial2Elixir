defmodule Persistencia do
   @moduledoc """
  modulo para escribir el reporte en un archivo txt
  """

  @ruta_reporte "resources/movimientos.txt"


  def guardar_reporte(texto_reporte) do
    texto_reporte
    |> File.write(@ruta_reporte)
    |> evaluar_resultado_escritura(texto_reporte)
  end


  defp evaluar_resultado_escritura(:ok, texto_reporte) do
    "El reporte se guardo en: #{@ruta_reporte}"
    |> Util.mostrar_mensaje()

    texto_reporte
  end

  defp evaluar_resultado_escritura({:error, razon}, _texto_reporte) do
    "Error: No se pudo guardar el reporte ya que: #{inspect(razon)}"
    |> Util.mostrar_error()
  end
end
