defmodule Cortex.ThingController do
  use Cortex.Web, :controller

  alias Cortex.Thing

  plug :scrub_params, "thing" when action in [:create, :update]

  def index(conn, _params) do
    things = Repo.all(Thing)
    render(conn, "index.html", things: things)
  end

  def new(conn, _params) do
    changeset = Thing.changeset(%Thing{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"thing" => thing_params}) do
    changeset = Thing.changeset(%Thing{}, thing_params)

    case Repo.insert(changeset) do
      {:ok, _thing} ->
        conn
        |> put_flash(:info, "Thing created successfully.")
        |> redirect(to: thing_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    thing = Repo.get!(Thing, id)
    render(conn, "show.html", thing: thing)
  end

  def edit(conn, %{"id" => id}) do
    thing = Repo.get!(Thing, id)
    changeset = Thing.changeset(thing)
    render(conn, "edit.html", thing: thing, changeset: changeset)
  end

  def update(conn, %{"id" => id, "thing" => thing_params}) do
    thing = Repo.get!(Thing, id)
    changeset = Thing.changeset(thing, thing_params)

    case Repo.update(changeset) do
      {:ok, thing} ->
        conn
        |> put_flash(:info, "Thing updated successfully.")
        |> redirect(to: thing_path(conn, :show, thing))
      {:error, changeset} ->
        render(conn, "edit.html", thing: thing, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    thing = Repo.get!(Thing, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(thing)

    conn
    |> put_flash(:info, "Thing deleted successfully.")
    |> redirect(to: thing_path(conn, :index))
  end
end
