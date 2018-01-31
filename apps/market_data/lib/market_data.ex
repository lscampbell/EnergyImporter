defmodule MarketData do
  @moduledoc false

  def import_index_file(file_path) do
    mapped_data =
      CSV.decode(File.stream!(file_path), headers: true)
      |> Enum.map(&map_index_item/1)
    ImportChannel.send_market_data "index", mapped_data
  end


  def import_index_dir(folder_path) do
      list_all(folder_path)
        |> Enum.map(&import_index_file/1)
  end


  def import_closing_price_file(file_path) do
    mapped_data =
      CSV.decode(File.stream!(file_path), headers: true)
      |> Enum.map(&map_closing_item/1)
    ImportChannel.send_market_data "closing", mapped_data
  end


  def import_closing_price_dir(folder_path) do
    list_all(folder_path)
      |> Enum.map(&import_closing_price_file/1)
  end


  def list_all(filepath) do
    _list_all(filepath)
  end


  defp map_index_item({:ok, source}) do
    %{
      date: parse_index_date(source["DealDate"]),
      instrument_name: source["InstrumentName"],
      index_name: source["IndexName"],
      high: source["High"],
      low: source["Low"],
      average: source["Average"],
      total_volume: source["TotalVolume"],
    }
  end


  defp map_closing_item({:ok, source}) do
    %{
      date: parse_closing_date(source["Price Date"]),
      instrument_name: source["InstrumentName"],
      sequence_name: source["SequenceName"],
      item_name: source["SequenceItemName"],
      bid: source["Bid"],
      offer: source["Offer"],
      change: value_or_zero(source["Change"]),
    }
  end


  defp value_or_zero("") do
    "0.0"
  end

  defp value_or_zero(value) do
    value
  end


  defp parse_index_date(str) do
    {:ok, date} = Timex.parse(str, "{D}-{Mshort}-{YY}")
    date
    |> Timex.to_date()
  end


  defp parse_closing_date(str) do
    {:ok, date} = Timex.parse(str, "{D}/{0M}/{YYYY} {h24}:{m}:{s}")
    date
    |> Timex.to_date()
  end


  defp _list_all(filepath) do
    cond do
      String.contains?(filepath, ".git") -> []
      true -> expand(File.ls(filepath), filepath)
    end
  end


  defp expand({:ok, files}, path) do
    files
    |> Enum.flat_map(&_list_all("#{path}/#{&1}"))
  end


  defp expand({:error, _}, path) do
    [path]
  end

end

# MarketData.import_index_file "/Users/pete/Downloads/Market Data/Spectrom/spectrom ftp site mirror/ftpserver.imarex.com/Spectrometer_Index_010210.csv"
# MarketData.import_closing_price_file "/Users/pete/Downloads/Market Data/Spectrom/spectrom ftp site mirror/ftpserver.imarex.com/Spectrometer_ClosingPrice_311210.csv"
# MarketData.import_index_dir "/Users/leecampbell/Downloads/Market Data/index/"
# MarketData.import_closing_price_dir "/Users/leecampbell/Downloads/Market Data/closing/"
Timex.parse "01-Feb-16", "{D}-{Mshort}-{YY}"
