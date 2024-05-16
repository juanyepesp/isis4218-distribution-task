defmodule Chat do
  def start do
    {:ok, _pid} = ChatServer.start_link([])

    # Example interactions
    pos_id1 = ChatServer.insert("Hello, world!")
    _pos_id2 = ChatServer.insert("This is a distributed chat.")

    # Deleting a message
    ChatServer.delete(pos_id1)
    ChatServer.print_all_messages()
    ChatServer.print_actual()
  end
end
