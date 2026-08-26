defmodule IvhsBrokerWeb.Html do
  def class(initial \\ "", classes)

  def class(initial, classes) when is_list(classes) do
    Enum.reduce(classes, initial, fn class, acc ->
      class(acc, class)
    end)
  end

  def class(initial, nil), do: initial
  def class(initial, ""), do: initial

  def class(initial, {true, class}), do: class(initial, class)
  def class(initial, {true, class, _}), do: class(initial, class)
  def class(initial, {false, _, class}), do: class(initial, class)

  def class(initial, {function, class}) when is_function(function, 0),
    do: class(initial, {function.(), class})

  def class(initial, {function, if_true, if_false}) when is_function(function, 0),
    do: class(initial, {function.(), if_true, if_false})

  def class("", ""), do: ""

  def class("", class) when is_binary(class), do: class

  def class(initial, ""), do: initial

  def class(initial, class) when is_binary(class), do: initial <> " " <> class

  def class(initial, _), do: initial
end
