# modulos para definir las estructuras basicas de ciudad y movimiento con sus parseos verificatorios

defmodule Ciudad do
  defstruct id_ciudad: "", nombre: "", numero_habitantes: 0

  #se parsea la linea separada por @ en un struct de ciudad, se validan que hayan 3 partesy que el numero de habitantes sea mayorr a 0, retorna un ok,ciudad si es valido o error si no
  def parsear_linea(linea) do
    case String.split(linea, "@") do
      [id, nombre, hab_str] when id != "" and nombre != "" and hab_str != "" ->
        case Integer.parse(hab_str) do
          {habitantes, ""} when habitantes > 0 ->
            {:ok, %Ciudad{id_ciudad: id, nombre: nombre, numero_habitantes: habitantes}}
          _ ->
            :error
        end
      _ ->
        :error
    end
  end
end


defmodule Movimiento do
  defstruct codigo: "", id_ciudad: "", hora_inicio: "", hora_final: "", magnitud: 0.0, profundidad: 0.0

  #se parsea la linea separada por @ en un struct de movimiento, se validan que hayan 6 partes, que las horas la magnitud y profundidad sean validos, retorna un ok,movimiento si es valido o error si no
  def parsear_linea(linea) do
    case String.split(linea, "@") do
      [cod, id_ciu, h_ini, h_fin, mag_str, prof_str]
        when cod != "" and id_ciu != "" and h_ini != "" and h_fin != "" and mag_str != "" and prof_str != "" ->
        if horas_validas?(h_ini, h_fin) do
          case {Float.parse(mag_str), Float.parse(prof_str)} do
            {{mag, ""}, {prof, ""}} when prof >= 0.0 ->
              {:ok, %Movimiento{ codigo: cod, id_ciudad: id_ciu, hora_inicio: h_ini, hora_final: h_fin, magnitud: mag, profundidad: prof}}
            _ ->
              :error
          end
        else
          :error
        end
      _ ->
        :error
    end
  end

  #funcion auxiliar par verificar las horas en formato ISO 8601
  defp horas_validas?(h_ini, h_fin) do
    case {Time.from_iso8601(h_ini), Time.from_iso8601(h_fin)} do
      {{:ok, _}, {:ok, _}} -> true
      _ -> false
    end
  end
end
