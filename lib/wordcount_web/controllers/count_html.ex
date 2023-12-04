defmodule WordcountWeb.CountHTML do
  use WordcountWeb, :html

  @moduledoc """
  Links the controller to the view, located in the folder count_html/.
  The html displayed is divided in three heex files :
  - root.html.heex, located in /lib/wordcount_web/components/layouts : defines the html, header and body tags
  - app.html.heex, located in /lib/wordcount_web/components/layouts : defines the main in the body
  - home.html.heex, located in /lib/wordcount_web/controllers/count_html : defines the custom html specific for the app
  """

  @doc """
  Displays the html view for the web app

  ## Parameters

    - assigns: List of HTML elements
  """
  embed_templates "count_html/*"
end
