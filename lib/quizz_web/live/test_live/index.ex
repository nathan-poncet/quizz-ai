defmodule QuizzWeb.TestLive.Index do
  use QuizzWeb, :live_view

  alias Quizz.Tests
  alias Quizz.Tests.Test

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tests, Tests.list_tests())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Test")
    |> assign(:test, Tests.get_test!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Test")
    |> assign(:test, %Test{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tests")
    |> assign(:test, nil)
  end

  @impl true
  def handle_info({QuizzWeb.TestLive.FormComponent, {:saved, test}}, socket) do
    {:noreply, stream_insert(socket, :tests, test)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    test = Tests.get_test!(id)
    {:ok, _} = Tests.delete_test(test)

    {:noreply, stream_delete(socket, :tests, test)}
  end
end
