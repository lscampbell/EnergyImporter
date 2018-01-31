defmodule ImportChannel do
  def send_market_data(type, payload) do
    ImportChannel.ImportChannelClient.push "import:market_data:#{type}", payload
  end
end
# ImportChannel.send_market_data "index", [%{}]
