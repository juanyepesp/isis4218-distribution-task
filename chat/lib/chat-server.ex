defmodule ChatServer do
  use GenServer

  alias Treedoc

  # Client API
  def start_link(_) do
    GenServer.start_link(__MODULE__, Treedoc.new(), name: __MODULE__)
  end

  def insert(msg) do
    GenServer.call(__MODULE__, {:insert, msg})
  end

  def delete(pos_id) do
    GenServer.cast(__MODULE__, {:delete, pos_id})
  end

  def print_all_messages do
    GenServer.call(__MODULE__, :print_all_messages)
  end

  def print_actual do
    GenServer.call(__MODULE__, :print_actual)
  end

  # Server Callbacks
  def init(treedoc) do
    {:ok, treedoc}
  end

  def handle_call({:insert, msg}, _from, treedoc) do
    {new_treedoc, id} = Treedoc.insert(treedoc, msg)
    {:reply, id, new_treedoc}
  end

  def handle_call(:print_all_messages, _from, treedoc) do
    Treedoc.print_all_messages(treedoc)
    {:reply, :ok, treedoc}
  end

  def handle_call(:print_actual, _from, treedoc) do
    Treedoc.print_actual(treedoc)
    {:reply, :ok, treedoc}
  end

  def handle_cast({:delete, pos_id}, treedoc) do
    new_treedoc = Treedoc.delete(treedoc, pos_id)
    {:noreply, new_treedoc}
  end
end
