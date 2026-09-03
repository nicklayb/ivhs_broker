defmodule IvhsBroker.Task.GenerateCover do
  use IvhsBroker, :task

  require Logger

  @impl IvhsBroker.Task
  def run(options) do
    cover_url = Keyword.fetch!(options, :url)

    prepare!()

    with {:ok, file_path} <- maybe_download_cover(cover_url, options),
         {:ok, cover_file_path} <- generate_cover(file_path, options) do
      {:ok, cover_file_path}
    end
  end

  defp generate_cover(source_file_path, options) do
    destination_file_name =
      options
      |> Keyword.get_lazy(:destination_file_name, fn -> hash(source_file_path) <> ".png" end)
      |> temporary_folder()

    case System.cmd(
           "node",
           [
             script_file_name("generate_card.mjs"),
             source_file_path,
             destination_file_name
           ]
         ) do
      {_, 0} ->
        Logger.debug(
          "[#{inspect(__MODULE__)}] [generate] #{source_file_path} -> #{destination_file_name}"
        )

        {:ok, destination_file_name}

      {out, code} ->
        {:error, {code, out}}
    end
  end

  defp maybe_download_cover(cover_url, options) do
    file_path =
      options
      |> Keyword.get_lazy(:source_file_name, fn -> hash(cover_url) <> ".jpg" end)
      |> temporary_folder()

    if not Keyword.get(options, :force_download, false) and File.exists?(file_path) do
      {:ok, file_path}
    else
      download_cover(cover_url, file_path, options)
    end
  end

  defp download_cover(cover_url, file_path, options) do
    headers = Keyword.get(options, :headers, [])

    with {:ok, _, _} <-
           IvhsBroker.Http.request_200(
             url: cover_url,
             headers: headers,
             raw: true,
             into: File.stream!(file_path)
           ) do
      Logger.debug("[#{inspect(__MODULE__)}] [download] #{cover_url}")
      {:ok, file_path}
    end
  end

  defp prepare! do
    File.mkdir_p!(temporary_folder())
  end

  defp temporary_folder(file_name \\ nil) do
    file_name = if is_nil(file_name), do: [], else: [file_name]

    :ivhs_broker
    |> :code.priv_dir()
    |> then(&Path.join([&1, "temp" | file_name]))
  end

  defp script_file_name(script_name) do
    :ivhs_broker
    |> :code.priv_dir()
    |> then(&Path.join([&1, "scripts", script_name]))
  end

  defp hash(input) do
    :sha256
    |> :crypto.hash(input)
    |> Base.encode16(case: :lower)
  end
end
