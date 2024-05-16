defmodule Treedoc do
  defstruct tree: %{}

  def new() do
    %Treedoc{}
  end

  def insert(%Treedoc{tree: tree} = doc, msg) do
    id = generate_id()
    updated_tree = Map.put(tree, id, %{msg: msg, deleted: false})
    {%Treedoc{doc | tree: updated_tree}, id}
  end

  def delete(%Treedoc{tree: tree} = doc, pos_id) do
    updated_tree = Map.update!(tree, pos_id, fn msg -> Map.put(msg, :deleted, true) end)
    %Treedoc{doc | tree: updated_tree}
  end

  def print_all_messages(%Treedoc{tree: tree}) do
    Enum.each(tree, fn {id, %{msg: msg, deleted: deleted}} ->
      status = if deleted, do: "(deleted)", else: ""
      IO.puts("#{id}: #{msg} #{status}")
    end)
  end

  def print_actual(%Treedoc{tree: tree}) do
    Enum.each(tree, fn {id, %{msg: msg, deleted: deleted}} ->
      unless deleted, do: IO.puts("#{id}: #{msg}")
    end)
  end

  defp generate_id() do
    :erlang.unique_integer([:positive])
  end
end
