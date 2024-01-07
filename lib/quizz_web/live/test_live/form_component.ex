defmodule QuizzWeb.TestLive.FormComponent do
  use QuizzWeb, :live_component

  alias Quizz.Tests

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage test records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="test-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Test</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{test: test} = assigns, socket) do
    changeset = Tests.change_test(test)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"test" => test_params}, socket) do
    changeset =
      socket.assigns.test
      |> Tests.change_test(test_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"test" => test_params}, socket) do
    save_test(socket, socket.assigns.action, test_params)
  end

  defp save_test(socket, :edit, test_params) do
    case Tests.update_test(socket.assigns.test, test_params) do
      {:ok, test} ->
        notify_parent({:saved, test})

        {:noreply,
         socket
         |> put_flash(:info, "Test updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_test(socket, :new, test_params) do
    case Tests.create_test(test_params) do
      {:ok, test} ->
        notify_parent({:saved, test})

        {:noreply,
         socket
         |> put_flash(:info, "Test created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
