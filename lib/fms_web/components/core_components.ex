defmodule FmsWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component, global_prefixes: ~w(x- data-bs- aria-)

  alias Phoenix.LiveView.JS
  import FmsWeb.Gettext

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr :id, :string, required: true
  attr :title, :string, default: nil
  attr :size, :string, default: "lg"
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :width, :string, default: "80"
  slot :inner_block, required: true
  slot :modal_footer

  def modal(assigns) do
    ~H"""
    <div id={@id} class="phx-modal fade-in">
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={hide_modal(@on_cancel, @id)}
        phx-window-keydown={hide_modal(@on_cancel, @id)}
        phx-key="escape"
        style={"width: #{@width}%;"}
      >
        <p id="close" class="phx-modal-close" phx-click={hide_modal(@on_cancel, @id)}>
          ✖
        </p>

        <.focus_wrap id={"#{@id}-container"}>
          <%= render_slot(@inner_block) %>
        </.focus_wrap>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil

  attr :kind, :atom,
    values: [:success, :info, :warning, :error],
    doc: "used for styling and flash lookup"

  attr :autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount"
  attr :close, :boolean, default: true, doc: "whether the flash can be closed"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "position-fixed top-0 end-0 w-25 rounded p-3 shadow mx-3 my-3",
        "alert",
        @kind == :success && "alert-success",
        @kind == :info && "alert-info",
        @kind == :warning && "alert-warning",
        @kind == :error && "alert-danger"
      ]}
      style="z-index: 1000;"
      {@rest}
    >
      <div class="row">
        <div class="col-10">
          <p :if={@title} class="d-flex align-items-center gap-1.5 fw-semibold">
            <i class={[
              "px-2 fa-solid",
              @kind == :success && "fa-check-circle",
              @kind == :info && "fa-info-circle",
              @kind in [:warning, :error] && "fa-exclamation-circle"
            ]} />
            <%= @title %>
          </p>
        </div>
        <div class="col-2 d-flex align-items-start">
          <button
            :if={@close}
            type="button"
            class="btn-close d-inline text-end"
            aria-label={gettext("Close")}
          >
          </button>
        </div>
      </div>
      <p class="mb-0"><%= msg %></p>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} title="Success!" flash={@flash} />
    <.flash kind={:success} title="Success!" flash={@flash} />
    <.flash kind={:error} title="Error!" flash={@flash} />
    <.flash kind={:warning} title="Warning!" flash={@flash} />
    <.flash
      id="disconnected"
      kind={:error}
      title="We can't find the internet"
      phx-disconnected={show("#disconnected")}
      phx-connected={hide("#disconnected")}
    >
      Attempting to reconnect <i class="fa-solid fa-rotate fa-spin"></i>
    </.flash>
    """
  end

  @doc """
  A simple alert component
  """
  attr :kind, :atom, values: [:success, :info, :warning, :danger, :error], default: :info
  attr :show, :boolean, default: false
  slot :inner_block, required: true

  def alert(assigns) do
    ~H"""
    <div
      :if={@show}
      class={[
        "alert",
        @kind == :info && "bg-gradient-primary",
        @kind == :success && "bg-gradient-success",
        @kind == :warning && "bg-gradient-warning",
        @kind in [:danger, :error] && "bg-gradient-danger",
        "alert-dismissible text-sm text-white fade show"
      ]}
      role="alert"
    >
      <%!-- <span class="alert-icon"><i class="ni ni-like-2"></i></span> --%>
      <span class="alert-text"><%= render_slot(@inner_block) %></span>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
        <i class="fa-solid fa-times"></i>
      </button>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  slot :extra_block,
    required: false,
    doc: "the optional extra block that renders extra form fields"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div>
        <%= render_slot(@inner_block, f) %>
        <div
          :for={action <- @actions}
          class="mt-2 d-flexflex align-items-center justify-content-between gap-3"
        >
          <%= render_slot(action, f) %>
        </div>
        <div :if={@extra_block != []}>
          <%= render_slot(@extra_block, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :kind, :atom,
    values: [
      :primary,
      :secondary,
      :tertiary,
      :info,
      :success,
      :warning,
      :danger,
      :dark,
      :gray,
      :light
    ],
    default: :dark

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "btn",
        @kind == :primary && "btn-primary",
        @kind == :secondary && "btn-secondary",
        @kind == :tertiary && "btn-tertiary",
        @kind == :info && "btn-info",
        @kind == :success && "btn-success",
        @kind == :warning && "btn-warning",
        @kind == :danger && "btn-danger",
        @kind == :dark && "btn-dark btn-md",
        @kind == :gray && "btn-gray-200",
        @kind == :light && "btn-gray-50",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :rest, :global, include: ~w(autocomplete cols disabled form max maxlength min minlength
                                   pattern placeholder readonly required rows size step)
  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div phx-feedback-for={@name}>
      <label class="form-label">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id || @name}
          name={@name}
          value="true"
          checked={@checked}
          class="form-check-input"
          {@rest}
        />
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select id={@id} name={@name} class="form-select" , multiple={@multiple} {@rest}>
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "radio"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="form-check">
      <input
        class="form-check-input"
        type="radio"
        name={@name}
        value={@value}
        id={@id}
        checked={@checked}
      />
      <label class="form-check-label" for={@id}>
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={["form-control", @errors != [] && "is-invalid"]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "form-control",
          @errors != [] && "is-invalid"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  attr :ref, :string, required: true
  attr :label, :string, required: true
  attr :upload, :map, required: true
  attr :width, :string, default: "w-full"
  slot :input_title, required: false
  slot :upload_description, required: false

  def upload_input(assigns) do
    ~H"""
    <div class="mb-3" phx-drop-target={@ref}>
      <.label for={@ref}><%= @label %></.label>
      <.live_file_input upload={@upload} class="form-control" />
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="form-label">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  A progress bar component
  """
  attr :progress, :integer, default: 0

  def progress_bar(assigns) do
    ~H"""
    <div
      class="progress"
      role="progressbar"
      aria-label="Animated striped example"
      aria-valuenow={@progress}
      aria-valuemin="0"
      aria-valuemax="100"
    >
      <div
        class="progress-bar progress-bar-striped progress-bar-animated"
        style={"width: #{@progress}%"}
      >
      </div>
    </div>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="invalid-feedback">
      <i class="fas fa-exclamation-circle mr-2"></i>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table_2(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <table class="table table-hover align-items-center">
      <thead>
        <tr>
          <th :for={col <- @col} class="border-bottom"><%= col[:label] %></th>
          <th class="border-bottom"><span><%= gettext("Actions") %></span></th>
        </tr>
      </thead>
      <tbody id={@id} phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}>
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
          <td
            :for={{col, _i} <- Enum.with_index(@col)}
            phx-click={@row_click && @row_click.(row)}
            class={[@row_click && "pe-auto"]}
          >
            <%= render_slot(col, @row_item.(row)) %>
          </td>
          <td :if={@action != []}>
            <span :for={action <- @action}>
              <%= render_slot(action, @row_item.(row)) %>
            </span>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
    attr :style, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <table class="table table-flush">
      <thead class="thead-light">
        <tr>
          <th :for={col <- @col} style={col[:style]} class="text-xs"><%= col[:label] %></th>
          <th class="text-xs"><span><%= gettext("Actions") %></span></th>
        </tr>
      </thead>
      <tbody id={@id} phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}>
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
          <td
            :for={{col, _i} <- Enum.with_index(@col)}
            phx-click={@row_click && @row_click.(row)}
            class={[@row_click && "text-sm"]}
          >
            <%= render_slot(col, @row_item.(row)) %>
          </td>
          <td :if={@action != []}>
            <span :for={action <- @action}>
              <%= render_slot(action, @row_item.(row)) %>
            </span>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <Heroicons.arrow_left solid class="w-3 h-3 stroke-current inline" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  attr :id, :string, default: "accordionExample"
  attr :rest, :global

  slot :item, required: true do
    attr :id, :string, required: true
    attr :heading, :string, required: true
    attr :class, :string
  end

  def accordion(assigns) do
    ~H"""
    <div class="accordion" id={@id}>
      <div :for={accordion_item <- @item} class="accordion-item">
        <h2 class="accordion-header">
          <button
            class="accordion-button"
            type="button"
            data-bs-toggle={accordion_item[:id]}
            data-bs-target={"##{accordion_item[:id]}"}
            aria-controls={accordion_item[:id]}
          >
            <%= accordion_item[:heading] %>
          </button>
        </h2>
        <div
          id={accordion_item[:id]}
          class={["accordion-collapse", accordion_item[:class]]}
          data-bs-parent={@id}
        >
          <div class="accordion-body">
            <%= render_slot(accordion_item) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(FmsWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(FmsWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
