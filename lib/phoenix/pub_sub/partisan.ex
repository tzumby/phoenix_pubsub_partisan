defmodule Phoenix.PubSub.Partisan do
  @moduledoc """
  Phoenix PubSub adapter using Partisan.

  You will need to add this to your supervision tree:
  ```elixir
  {Phoenix.PubSub,
    [name: MyApp.PubSub,
     adapter: Phoenix.PubSub.Partisan
  }
  ```

  """

  @behaviour Phoenix.PubSub.Adapter
  use GenServer

  alias Phoenix.PubSub.Partisan.BroadcastHandler

  @doc """
  Start the server

  This function is called by `Phoenix.PubSub`
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:adapter_name])
  end

  @doc false
  def init(opts) do
    state = %{
      pubsub_name: opts[:name]
    }

    {:ok, state, {:continue, :create_tables}}
  end

  def handle_continue(:create_tables, state) do
    :ets.new(:partisan_broadcast_messages, [:set, :public, :named_table])
    {:noreply, state}
  end

  @doc false
  def node_name(nil), do: :partisan.node()
  def node_name(custom_name), do: custom_name

  def direct_broadcast(server, node_name, topic, message, dispatcher) do
  end

  def handle_cast({:broadcast, message}, state) do
    :partisan_plumtree_broadcast.broadcast(
      Map.merge(message, %{pubsub_name: state.pubsub_name}),
      BroadcastHandler
    )

    {:noreply, state}
  end

  def broadcast(adapter_name, topic, message, _dispatcher, _metadata \\ %{}) do
    GenServer.cast(adapter_name, {:broadcast, %{topic: topic, message: message}})
  end
end
