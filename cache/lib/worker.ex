defmodule Cache.Worker do
  use GenServer

  @name CW

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: CW])
  end

  def write(key, value) do
    GenServer.cast(@name, {:write, key, value})
  end

  def read(key) do
    GenServer.call(@name, {:read, key})
  end

  def delete(key) do
    GenServer.cast(@name, {:delete, key})
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def exist?(key) do
    GenServer.call(@name, {:exist, key})
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  # Server Callbacks
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:write, key, value}, old_cache) do
    new_cache = update_cache(old_cache, key, value)
    {:noreply, new_cache}
  end

  def handle_cast(:clear, _old_cache) do
    {:noreply, %{}}
  end

  def handle_cast({:delete, key}, old_cache) do
    new_cache = Map.delete(old_cache, key)
    {:noreply, new_cache}
  end

  def handle_cast(:stop, cache) do
    {:stop, :normal, cache}
  end

  def handle_call({:read, key}, _from, cache) do
    value = Map.get(cache, key)
    {:reply, value, cache}
  end
 

  def handle_call({:exist, key}, _from, cache) do
    res = Map.has_key?(cache, key)
    {:reply, res, cache}
  end


  def terminate(reason, cache) do
    IO.puts "server terminated because of #{inspect reason}"
    inspect cache
    :ok
  end
      

  # Helpers
  defp update_cache(old_cache, key, value) do
    case Map.has_key?(old_cache, key) do
      true ->
        Map.update!(old_cache, key, value)
      false ->
        Map.put_new(old_cache, key, value)
    end
  end



end
