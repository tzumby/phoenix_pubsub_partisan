defmodule Phoenix.PubSub.Partisan.BroadcastHandler do
  @behaviour :partisan_plumtree_broadcast_handler

  require Logger

  # Return a two-tuple of message id and payload from a given broadcast
  # This is called by the broadcast/2 method of partisan_plumtree_broadcast.erl
  # module 
  def broadcast_data(%{id: id} = data) do
    {id, data}
  end

  # Return the channel to be used when broadcasting data associate with this
  # handler
  def broadcast_channel() do
    :undefined
  end

  # Given the message id and payload, merge the message in the local state.
  # If the message has already been received return `false', otherwise return `true'
  # # Called by handle_cast({:broadcast, ...}) in partisan_plumtree_broadcast.erl 
  def merge(id, %{message: message, pubsub_name: pubsub_name, topic: topic} = payload) do
    Logger.info(
      "Merging message #{inspect(id)}, #{inspect(payload)} on node: #{inspect(:partisan.node())}"
    )

    case :ets.lookup(:partisan_broadcast_messages, id) do
      [] ->
        :ets.insert(:partisan_broadcast_messages, {id, payload})

        Registry.dispatch(pubsub_name, topic, fn entries ->
          for {pid, _} <- entries, do: send(pid, {:broadcast, message})
        end)

        true

      _ ->
        false
    end
  end

  # Return true if the message (given the message id) has already been received.
  # `false' otherwise
  def is_stale(id) do
    Logger.info("is_stale #{inspect(id)} on node: #{inspect(:partisan.node())}")

    case :ets.lookup(:partisan_broadcast_messages, id) do
      [] -> false
      _ -> true
    end
  end

  # Return the message associated with the given message id. In some cases a
  # message has already been sent with information that subsumes the message
  # associated with the given message id. In this case, `stale' is returned.
  def graft(id) do
    Logger.info("graft #{inspect(id)} on node: #{inspect(:partisan.node())}")

    case :ets.lookup(:partisan_broadcast_messages, id) do
      [] -> {:error, {:not_found, id}}
      [{_id, message}] -> {:ok, message}
    end
  end

  # Trigger an exchange between the local handler and the handler on the given
  # node.
  # How the exchange is performed is not defined but it should be performed as a
  # background process and ensure that it delivers any messages missing on
  # either the local or remote node.
  # The exchange does not need to account for messages in-flight when it is
  # started or broadcast during its operation. These can be taken care of in
  # future exchanges.
  def exchange(_node) do
    :ignore
  end
end
