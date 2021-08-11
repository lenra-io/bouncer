# Bouncer

Bouncer is a simple library that allow to create permission policy and use them with a simple Bouncer.allow/4 function.

The policy is defined by implementing the ```Bouncer.Policy``` behavior and implementing the ```authorize/3``` function. It has been designed with Phoenix Framework in mind.
```elixir

# First we define the Policy using the behavior
defmodule MyApp.Policy do
  @behaviour Bouncer.Policy

  @impl true
  # The authorize/3 function take:  
  # - the atom representing the current user action
  # - the user struct/map or anything that represent a resource/user/account
  # - Any metadata useful to check permissions

  # If the user is an admin, he can do everything
  def authorize(_, %User{role: :admin}, _), do: true
  # any one can acces the index page
  def authorize(:index, _, _), do: true
  # Only verified user can create the resource
  def authorize(:create, %User{role: :verified_user}, _), do: true
  # Only the owner of the resource can update or delete the resource.
  # We use pattern matching on id to ensure that the id is the same.
  # If the id of the user and the user owner is different, it will not match.
  # We also use guard to group the rule of :create and :delete
  def authorize(action, %User{id: id}, %Resource{owner: User{id: id}}) when action in [:create, :delete], do: true
  # Good practice, deny everything else baseline.
  def authorize(_, _, _), do: false
end

defmodule MyApp do
  # then we can use the allow/3 or allow?/3 function to check permissions.
  # The allow/3 function is designed to be used inside the `with` flow control.
  # the allow?/3 function can be use in Enum.filter, if...
  def index do
    with {:ok, user} <- fetchMyUser(),
          :ok <- Bouncer.allow(MyApp.Policy, :index, user, nil) do
      myStuff()
    end
  end
end

```

You can also create some macro to help you with the boilerplate, especially with the module name, action and the user/resource.

Here an example of what you can do. This using macro transform the allow/4 function into a allow/2 function that take the conn and the metadata.

```elixir
defmodule MyApp.Policy do

  defmacro __using__(opts \\ []) do
    policy_module = Keyword.get(opts, :module)

    quote do
      @spec allow(any(), any()) :: :ok | {:error, atom()}
      def allow(conn, params \\ nil) do
        Bouncer.allow(
          unquote(policy_module),
          Plug.action_name(conn),
          getMyUserFromConn(conn),
          params
        )
      end
    end
  end
end

```

It can be used on Phoenix controller like that : 
```elixir
defmodule MyApp.MyController do
  use LenraWeb, :controller

  use LenraWeb.Policy,
    module: MyApp.MyController.Policy

  def index(conn, %{id: resource_id}) do
    with {:ok, resource} <- fetchResource(resource_id)
        :ok <- allow(conn, resource) do
      doStuff()
    end
  end


end
```

## Installation

The package is curently not available in hexpm. It will be in near future.

In the meantime you can add it to dependancies using git deps

```elixir
def deps do
  [
    {:bouncer, git: "git@github.com:LenraOfficial/bouncer.git", tag: "v1.0.0-beta.1"}
end
```
