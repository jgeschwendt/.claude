defmodule Web.Layouts do
  @moduledoc """
  Layouts for the dashboard. Only the root layout is used — every LiveView
  renders its own full-screen chrome (see `Web.UI`).
  """
  use Web, :html

  embed_templates "layouts/*"
end
