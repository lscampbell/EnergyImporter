defmodule ImportChannel.Worker do
  @moduledoc false

  use GenServer

  def start_link(state, _opts) do
    GenServer.start_link __MODULE__, state, name: __MODULE__
  end


  def init(_opts) do
    {:ok, _} = ImportChannel.ImportSocket.start_link()
    {:ok, _} =
      PhoenixChannelClient.channel(ImportChannel.ImportChannelClient,
                                   socket: ImportChannel.ImportSocket,
                                   topic: "import:data")
    ImportChannel.ImportChannelClient.join %{}
    {:ok, %{}}
  end


  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end


  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end
