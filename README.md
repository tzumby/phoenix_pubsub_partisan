# PhoenixPubsubPartisan

🚧 Please don't use in production, the Adapter implementation is not complete.

This assumes you have a cluster of nodes connected with Partisan already. You 
need to start the PubSub server in your application supervision tree and 
configure it to use the custom Partisan adapter. 


```elixir

    children = [
      ...
      {Phoenix.PubSub, name: Example.PubSub, adapter: Phoenix.PubSub.Partisan}
      ...
    ]

```

You can then subscribe and broadcast:

node A:

```elixir 
> iex(1)> Phoenix.PubSub.subscribe(Example.PubSub, "user:123")
```

node B: 

```elixir
> iex(1)> Phoenix.PubSub.broadcast(Example.PubSub, "user:123", "hello")
```

node A:

```elixir 
> iex(2)> flush()
{:broadcast, "hello"}
```

Your iex process is the one that ends up being subscribed, hence why you can 
flush the message like that. 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phoenix_pubsub_partisan` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_pubsub_partisan, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/phoenix_pubsub_partisan>.

