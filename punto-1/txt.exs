defmodule Txt do
  @moduledoc """
  modulo para leer archivos txt
  """

  #se lee el archivo y se parsea cada linea, retorna la tupla valida o la de error
  def leer_txt(ruta_archivo, parser) do
    case File.read(ruta_archivo) do
      {:ok, contenido} ->
        contenido
        |> String.split("\n")
        |> procesar_lineas(parser, [], 0)

      {:error, _razon} ->
        {:error, ruta_archivo}
    end
  end

  #caso base cunado la lista esta vacia, como se agrrega a la cabeza lo invertimos
  defp procesar_lineas([], _parser, validos, rechazados) do
    {Enum.reverse(validos), rechazados}
  end

  #caso recursivo donde se evalua la linea actual, se ignoran las lineas vacias, si es valida se agrega a la lista y sino se cuenta como rechazado
  defp procesar_lineas([linea | resto], parser, validos, rechazados) do
    linea_limpia = String.trim(linea)

    cond do
      linea_limpia == "" ->
        procesar_lineas(resto, parser, validos, rechazados)

      true ->
        case parser.(linea_limpia) do
          {:ok, dato_valido} ->
            procesar_lineas(resto, parser, [dato_valido | validos], rechazados)

          :error ->
            procesar_lineas(resto, parser, validos, rechazados + 1)
        end
    end
  end
end
