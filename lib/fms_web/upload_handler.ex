defmodule FmsWeb.UploadHandler do
  import Phoenix.LiveView, only: [consume_uploaded_entries: 3]
  use FmsWeb, :verified_routes

  def save(socket, entries_key) do
    consume_uploaded_entries(socket, entries_key, fn %{path: path}, entry ->
      dest =
        Path.join([
          :code.priv_dir(:fms),
          "static",
          "uploads",
          "#{Path.basename(path)}.#{ext(entry)}"
        ])

      File.cp!(path, dest)
      {:ok, ~p"/uploads/#{Path.basename(dest)}"}
    end)
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end
end
