defmodule Cortex.ThingControllerTest do
  use Cortex.ConnCase

  alias Cortex.Thing
  @valid_attrs %{code: "some content", firmware_name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, thing_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing things"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, thing_path(conn, :new)
    assert html_response(conn, 200) =~ "New thing"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, thing_path(conn, :create), thing: @valid_attrs
    assert redirected_to(conn) == thing_path(conn, :index)
    assert Repo.get_by(Thing, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, thing_path(conn, :create), thing: @invalid_attrs
    assert html_response(conn, 200) =~ "New thing"
  end

  test "shows chosen resource", %{conn: conn} do
    thing = Repo.insert! %Thing{}
    conn = get conn, thing_path(conn, :show, thing)
    assert html_response(conn, 200) =~ "Show thing"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, thing_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    thing = Repo.insert! %Thing{}
    conn = get conn, thing_path(conn, :edit, thing)
    assert html_response(conn, 200) =~ "Edit thing"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    thing = Repo.insert! %Thing{}
    conn = put conn, thing_path(conn, :update, thing), thing: @valid_attrs
    assert redirected_to(conn) == thing_path(conn, :show, thing)
    assert Repo.get_by(Thing, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    thing = Repo.insert! %Thing{}
    conn = put conn, thing_path(conn, :update, thing), thing: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit thing"
  end

  test "deletes chosen resource", %{conn: conn} do
    thing = Repo.insert! %Thing{}
    conn = delete conn, thing_path(conn, :delete, thing)
    assert redirected_to(conn) == thing_path(conn, :index)
    refute Repo.get(Thing, thing.id)
  end
end
