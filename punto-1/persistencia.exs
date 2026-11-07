defmodule Persistencia do
  @moduledoc """
  modulo para escribir el reporte en un archivo txt
  """

  @ruta_reporte "resources/reporte_sismos.txt"

  def guardar_reporte(texto_reporte) do
    # asegura que la carpeta resources exista en disco
    Path.dirname(@ruta_reporte) |> File.mkdir_p!()

    # File.write recibe primero la ruta y luego el contenido
    File.write(@ruta_reporte, texto_reporte)
    |> evaluar_resultado_escritura(texto_reporte)
  end

  defp evaluar_resultado_escritura(:ok, texto_reporte) do
    "Reporte guardado en: #{@ruta_reporte}"
    |> Util.mostrar_mensaje()

    texto_reporte
  end

  defp evaluar_resultado_escritura({:error, razon}, _texto_reporte) do
    "Error al guardar el reporte: #{inspect(razon)}"
    |> Util.mostrar_error()
  end
end
