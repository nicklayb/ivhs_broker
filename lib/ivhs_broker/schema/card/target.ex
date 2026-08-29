defmodule IvhsBroker.Schema.Card.Target do
  @type payload :: %{media_content_type: String.t(), media_content_id: String.t()}

  @callback to_payload(struct()) :: payload()

  defmacro __using__(_) do
    quote do
      use IvhsBroker, :embedded_schema
      @behaviour IvhsBroker.Schema.Card.Target
    end
  end
end
