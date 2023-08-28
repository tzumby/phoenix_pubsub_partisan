defmodule Phoenix.PubSub.Partisan.BroadcastHandler do
  @behaviour :partisan_plumtree_broadcast_handler

  # Return a two-tuple of message id and payload from a given broadcast
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
  def merge(id, %{message: message, pubsub_name: pubsub_name, topic: topic} = payload) do
    :ets.insert(:partisan_broadcast_messages, {id, payload})

    Registry.dispatch(pubsub_name, topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:broadcast, message})
    end)

    true
  end

  # Return true if the message (given the message id) has already been received.
  # `false' otherwise
  def is_stale(id) do
    case :ets.lookup(:partisan_broadcast_messages, id) do
      result when result != [] -> false
      _ -> true
    end
  end

  # Return the message associated with the given message id. In some cases a
  # message has already been sent with information that subsumes the message
  # associated with the given message id. In this case, `stale' is returned.
  def graft(id) do
    case :ets.lookup(:partisan_broadcast_messages, id) do
      [{_message_id, payload}, _] -> payload
      _ -> nil
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
