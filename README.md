<div id="top"></div>
<!--
*** This README was created with https://github.com/othneildrew/Best-README-Template
-->



<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">Bouncer</h3>

  <p align="center">
    Bouncer is a simple library that allow to create your permission policy using a simple behavior. It was built with <a href="https://www.phoenixframework.org/">Phoenix framework</a> in mind but can be adapted to many more situations.<br />
    Built With <a href="https://elixir-lang.org/">Elixir</a>
    <!-- <br />
    <a href="https://github.com/lenra-io/bouncer"><strong>Explore the docs »</strong></a> -->
    <br />
    <br />
    <!-- <a href="https://github.com/lenra-io/bouncer">View Demo</a> ·-->
    <a href="https://github.com/lenra-io/bouncer/issues">Report Bug</a>
    ·
    <a href="https://github.com/lenra-io/bouncer/issues">Request Feature</a>
  </p>
</div>




<!-- GETTING STARTED -->

## Installation

The package is curently not available in [hexpm](https://hex.pm/) but we are planning to add it in a near future.

In the meantime you can add it to your project dependancies using git.

```elixir
def deps do
  [
    {:bouncer, git: "https://github.com/lenra-io/bouncer.git", tag: "vx.y.z"}
  ]
end
```

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

Bouncer is designed around the ```Bouncer.Policy``` behavior. You just have to create a ```MyApp.Policy``` module and implement the ```authorize/3``` function.
The following example are used with Phoenix controllers.

```elixir

# First we define the Policy using the behavior for a specific Controller
defmodule MyApp.MyController.Policy do
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
```

Now that the policy is defined, you just have to use ```Bouncer.allow/4``` or ```Bouncer.allow?/4``` to check if the given resource can do the given action with a given metadata.

```elixir
defmodule MyApp do
  # The allow/3 function is designed to be used inside the `with` flow control.
  # the allow?/3 function can be use in Enum.filter, if...
  def index do
    with {:ok, user} <- fetch_my_user(),
          :ok <- Bouncer.allow(MyApp.Policy, :index, user, nil) do
      do_my_stuff()
    end
  end
end

```

Since this can add a lot of repetitive code such as fetching user, specify the module and the action, you can also create some macro to help you shorten the ```Bouncer.allow``` call.

In this example, we will create a macro that will automatically extract the user from the conn and pass the Policy module and the controller action. This will transform the allow/4 function into a allow/2 function that take the conn and the metadata.

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
          get_user(conn),
          params
        )
      end
    end
  end
end

```

Then, use it on the Phoenix controller like so
```elixir
defmodule MyApp.MyController do
  use MyApp, :controller

  use MyApp.Policy,
    module: MyApp.MyController.Policy

  def index(conn, %{id: resource_id}) do
    with {:ok, resource} <- fetchResource(resource_id)
        :ok <- allow(conn, resource) do
      doStuff()
    end
  end


end
```

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please open an issue with the tag "enhancement".
Don't forget to give the project a star if you liked it! Thanks again!

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the **MIT** License. See [LICENSE](./LICENSE) for more information.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Lenra - [@lenra_dev](https://twitter.com/lenra_dev) - contact@lenra.io

Project Link: [https://github.com/lenra-io/bouncer](https://github.com/lenra-io/bouncer)

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/lenra-io/bouncer.svg?style=for-the-badge
[contributors-url]: https://github.com/lenra-io/bouncer/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/lenra-io/bouncer.svg?style=for-the-badge
[forks-url]: https://github.com/lenra-io/bouncer/network/members
[stars-shield]: https://img.shields.io/github/stars/lenra-io/bouncer.svg?style=for-the-badge
[stars-url]: https://github.com/lenra-io/bouncer/stargazers
[issues-shield]: https://img.shields.io/github/issues/lenra-io/bouncer.svg?style=for-the-badge
[issues-url]: https://github.com/lenra-io/bouncer/issues
[license-shield]: https://img.shields.io/github/license/lenra-io/bouncer.svg?style=for-the-badge
[license-url]: https://github.com/lenra-io/bouncer/blob/master/LICENSE.txt

