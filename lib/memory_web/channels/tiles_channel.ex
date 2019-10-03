defmodule MemoryWeb.TilesChannel do
  use MemoryWeb, :channel
  alias Memory.Tile

  def join("tiles:" <> name, payload, socket) do
    if authorized?(payload) do
      tile = Tile.new()
      socket = socket
      |> assign(:tile, tile)
      |> assign(:name, name)
      {:ok, %{"join" => name,"tile" => Tile.view(tile)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("select", %{"tile_id" => tile_id}, socket) do
     tile = Tile.select(socket.assigns[:tile],tile_id)
     socket = assign(socket, :tile, tile)
     {:reply, {:ok, %{ "tile" => Tile.view(tile)}}, socket}
  end

  def handle_in("clear_active", payload, socket) do
     tile = Tile.clear_active(socket.assigns[:tile])
     socket = assign(socket, :tile, tile)
     {:reply, {:ok, %{ "tile" => Tile.view(tile)}}, socket}
  end

  def handle_in("reset", payload, socket) do
     tile = Tile.new()
     socket = assign(socket, :tile, tile)
     {:reply, {:ok, %{ "tile" => Tile.view(tile)}}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (tiles:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end