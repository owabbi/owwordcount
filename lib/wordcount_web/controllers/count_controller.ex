defmodule WordcountWeb.CountController do
  # Use the WordcountWeb controller and import HTTPoison for HTTP requests
  use WordcountWeb, :controller
  import HTTPoison

  @moduledoc """

  """

  @doc """
  Function called when first getting on the homepage

  ## Parameters

    - conn : Connector
  """

  # Function called when first getting on the homepage
  def index(conn, _params) do
    # Render the home template with initial values
    # word_count : the number of words on the page
    # words : list of all the words and the number of times they are called
    # top_word : the most called word
    # url_preview : the text written in the input tag as placeholder
    # error_url : true if there is an error
    # error_reason : reason of the error
    # search_flag : true if an URL has been entered
    render(conn, :home, word_count: 0, words: %{}, top_word: "", url_preview: "", error_url: false, error_reason: "", search_flag: false, layout: false)
  end

  @doc """
  Count the number of words

  ## Parameters

    - conn : Connector
    - params : contains the url address submitted by the form
  """

  # Count the number of words
  def count_words(conn, params) do
    # Extract the "url" parameter from the request
    %{"url" => url } = params

    # Fetch word count from the provided URL
    case fetch_word_count(url) do
      {:ok,result} ->
        # If successful, extract and render the word count details
        {word_count, words, top_word} = result
        render(conn, :home, word_count: word_count, words: words, top_word: top_word, url_preview: url, error_url: false, error_reason: "", search_flag: true)
      {:error, reason} ->
        # If an error occurs, log the reason and render with error details
        render(conn, :home, word_count: 0, words: %{}, top_word: "", url_preview: url, error_url: true, error_reason: reason, layout: false, search_flag: true)
    end
  end

  # Fetch the word count from the provided URL
  defp fetch_word_count(url) do
    case get(url) do
      {:ok, %{status_code: 200, body: body}} ->

        # Extract text from HTML, filter, and count word frequencies
        words = body
        |> extract_text
        |> filter_text
        |> String.split(~r/\s+/) # Split the string by spaces
        |> Enum.filter(fn x -> x != "" end) # Remove the empty strings ("")

        # Create a map linking each word to the number of times it is written
        frequencies = Enum.reduce(words, %{}, fn word, acc ->
          # For each word encountered,
          # -> if the word is not in the map, add it with a count of 1.
          # -> if the word is already in the map, increment it's count by 1
          Map.update(acc, word, 1, &(&1 + 1))
        end)

        # Sort the previous map by the count of word in an ascending manner. Similar to Bubble sort but with the highest value in the first position.
        sorted_words = Enum.sort(frequencies, fn {_word1, count1}, {_word2, count2} -> count2 < count1 end)

        # Check if there is at least one word
        if length(sorted_words) > 0 do
          # Extract the top word and return word count details
          {top_word, _number } = List.first(sorted_words)
          {:ok, {Enum.count(words), sorted_words, top_word}}
        else
            # If there is no word on the page, send an empty list and set the word_count to 0.
            {:ok, {0, [], ""}}
        end

      {:ok, %{status_code: status_code, body: _body}} ->
        # Handle unexpected status code
        {:error, "Unexpected status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        # Handle HTTP request failure
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  # Extract text content from HTML using Floki
  defp extract_text(html) do
    {:ok, document} = Floki.parse_document(html)

     Floki.find(document, "html")
     |> Floki.text(sep: " ") # The seperator is necessary to add a space between opening and closing tags
  end

  # Filter text to remove non-alphanumeric characters and convert to lowercase
  defp filter_text(text) do
    text
    |> String.replace(~r/[^0-9A-Za-z']/, " ") # An improvement for the future : Add accent (é, è, etc), and fixe the apostrophe issue ("You'd" becomes "You d" and "d" is counted as an individual word)
    |> String.downcase # The downcase is needed because of the case sensitivity
  end
end
