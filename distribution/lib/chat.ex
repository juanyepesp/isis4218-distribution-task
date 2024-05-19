defmodule Chat do
  @node_name "node_2"

  def insert({pos_id, str}) do
    IO.puts("pos_id: #{pos_id}, str: #{str}")
    Agent.update(:treedoc, &Treedoc.insert(&1, {pos_id, str}))
  end

  def delete(pos_id) do
    IO.puts("pos_id: #{pos_id}")
    Agent.update(:treedoc, &Treedoc.delete(&1, pos_id))
  end

  def print_all_messages() do
    Agent.get(:treedoc, &Treedoc.print_all_messages(&1))
  end

  def print_actual() do
    Agent.get(:treedoc, &Treedoc.print_actual(&1))
  end

  def send_message(recipient, message, :insert) do
    spawn_task(__MODULE__, :insert, recipient, [message])
  end

  def send_message(recipient, message, :delete) do
    spawn_task(__MODULE__, :delete, recipient, [message])
  end

  def spawn_task(module, fun, recipient, args) do
    recipient
    |> remote_supervisor()
    |> Task.Supervisor.async(module, fun, args)
    |> Task.await()
  end

  defp remote_supervisor(recipient) do
    {Chat.TaskSupervisor, recipient}
  end

  def option_loop() do
    IO.puts("\n1. Send message")
    IO.puts("2. Delete message")
    IO.puts("3. Print all messages")
    IO.puts("4. Print actual messages")
    IO.puts("5. Exit")

    case IO.gets("Choose an option: ") |> String.trim() do
      "1" ->
        msg = IO.gets("Enter message: ") |> String.trim()
        element = {:os.system_time(), msg}
        # Agent.update(:treedoc, &Treedoc.insert(&1, element))
        insert(element)

        Enum.each(Node.list(), fn node ->
          send_message(node, element, :insert)
        end)

      "2" ->
        pos_id =
          IO.gets("Enter message id: ")
          |> String.trim()
          |> String.to_integer()

        # Agent.update(:treedoc, &Treedoc.delete(&1, pos_id))
        delete(pos_id)

        Enum.each(Node.list(), fn node ->
          send_message(node, pos_id, :delete)
        end)

      "3" ->
        print_all_messages()

      "4" ->
        print_actual()

      "5" ->
        IO.puts("Exiting...")
        exit(:normal)

      _ ->
        IO.puts("Invalid option")
    end

    option_loop()
  end

  def main do
    Agent.start_link(fn -> Treedoc.new() end, name: :treedoc)
    option_loop()
  end
end
