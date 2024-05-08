defmodule DuckDuckGooseWeb.ErrorJSONTest do
  use DuckDuckGooseWeb.ConnCase, async: true

  test "renders 404" do
    assert DuckDuckGooseWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert DuckDuckGooseWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
