defmodule LighthouseWeb.SafetyNetLive do
  use LighthouseWeb, :live_view

  def render(assigns) do
    # IO.inspect(assigns.ships, label: "Ship data")

    ~L"""
    <div class="flex p-4">

      <div style="position: relative; width: 712px; height: 710px; background-color: lightblue;">
        <!-- Loop through ships and position them based on their coordinates -->
        <%= for {id, ship} <- @ships do %>
        <div
            id="ship_<%= id %>"
            phx-update="replace"
            style="position: absolute; width: 32px; height: 32px;
              top: <%= elem(ship.coords, 1) * 20 %>px; left: <%= elem(ship.coords, 0) * 20 %>px;">
            <span class="text-4xl">⛵</span><span class="text-lg"><%= id %></span>
          </div>
        <% end %>
      </div>

      <div class="px-4">
        <h1 class="text-2xl font-medium pb-4">⚓ SafetyNet Lighthouse</h1>

        <div class="flex">
          <div class="w-2xs">
            <h2 class="text-xl font-medium pb-2">Ships</h2>
            <%= for {id, ship} <- @ships do %>
              <p><%= id %>:
                <span class="<%= if ship.status == :failed, do: "text-red-500", else: "" %>">
                  <%= if ship.status in [:alive, :failed], do: Atom.to_string(ship.status) %>
                  <%= if match?({:searching_for, _}, ship.status), do: "searching for #{elem(ship.status, 1)}" %>
                </span>, incarnation: <%= ship.inc %>, peers: <%= ship.peers %>
              </p>
            <% end %>
          </div>

          <div class="px-4 w-xs">
            <h2 class="text-xl font-medium pb-2">Messages</h2>
            <%= for msg <- @messages do %>
              <p><%= msg %></p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Lighthouse.PubSub, "fleet:updates")
    socket = assign(socket, ships: %{}, messages: [])
    {:ok, socket}
  end

  def handle_info({:ship_update, %{id: id, status: status, coords: coords, incarnation: inc, peers: peers}}, socket) do
    ships = socket.assigns.ships
    updated_ships = Map.put(ships, id, %{coords: coords, status: status, inc: inc, peers: peers})
    socket = assign(socket, ships: updated_ships)

    {:noreply, socket}
  end

  def handle_info({:message, msg}, socket) do
    socket = assign(socket, messages: [msg | socket.assigns.messages])
    {:noreply, socket}
  end
end
