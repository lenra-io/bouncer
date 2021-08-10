defmodule BouncerTest do
  use ExUnit.Case

  defmodule Account do
    defstruct [:id, role: :user]
  end

  defmodule TestBehavior do
    @behaviour Bouncer.Policy

    @impl true
    def authorize(:allow_any, _, _), do: true
    def authorize(:allow_none, _, _), do: false
    def authorize(:allow_user, %Account{role: :user}, _), do: true
    def authorize(:allow_user, _, _), do: false
    def authorize(:allow_same_account, %Account{id: id}, %Account{id: id}), do: true
    def authorize(:allow_same_account, _, _), do: false
    def authorize(:custom_error, _, _), do: {:error, :custom}
  end

  describe "allow" do
    test "any" do
      assert Bouncer.allow(TestBehavior, :allow_any, nil, nil) == :ok
    end

    test "none" do
      assert Bouncer.allow(TestBehavior, :allow_none, nil, nil) == {:error, :forbidden}
    end

    test "custom error" do
      assert Bouncer.allow(TestBehavior, :custom_error, nil, nil) == {:error, :custom}
    end

    test "user role" do
      assert Bouncer.allow(TestBehavior, :allow_user, %{role: :user}, nil) == {:error, :forbidden}

      assert Bouncer.allow(TestBehavior, :allow_user, %Account{role: :user}, nil) == :ok

      assert Bouncer.allow(TestBehavior, :allow_user, %Account{role: :any}, nil) ==
               {:error, :forbidden}
    end

    test "same account" do
      assert Bouncer.allow(TestBehavior, :allow_same_account, nil, nil) == {:error, :forbidden}

      assert Bouncer.allow(TestBehavior, :allow_same_account, %{id: 2}, %{id: 2}) ==
               {:error, :forbidden}

      assert Bouncer.allow(TestBehavior, :allow_same_account, %Account{id: 2}, %{id: 2}) ==
               {:error, :forbidden}

      assert Bouncer.allow(TestBehavior, :allow_same_account, %Account{id: 2}, %Account{id: 3}) ==
               {:error, :forbidden}

      assert Bouncer.allow(TestBehavior, :allow_same_account, %Account{id: 2}, %Account{id: 2}) ==
               :ok
    end
  end

  describe "allow?" do
    test "any" do
      assert Bouncer.allow?(TestBehavior, :allow_any, nil, nil) == true
    end

    test "none" do
      assert Bouncer.allow?(TestBehavior, :allow_none, nil, nil) == false
    end

    test "custom error" do
      assert Bouncer.allow?(TestBehavior, :custom_error, nil, nil) == false
    end

    test "user role" do
      assert Bouncer.allow?(TestBehavior, :allow_user, %{role: :user}, nil) == false
      assert Bouncer.allow?(TestBehavior, :allow_user, %Account{role: :user}, nil) == true
      assert Bouncer.allow?(TestBehavior, :allow_user, %Account{role: :any}, nil) == false
    end

    test "same account" do
      assert Bouncer.allow?(TestBehavior, :allow_same_account, nil, nil) == false
      assert Bouncer.allow?(TestBehavior, :allow_same_account, %{id: 2}, %{id: 2}) == false
      assert Bouncer.allow?(TestBehavior, :allow_same_account, %Account{id: 2}, %{id: 2}) == false

      assert Bouncer.allow?(TestBehavior, :allow_same_account, %Account{id: 2}, %Account{id: 3}) ==
               false

      assert Bouncer.allow?(TestBehavior, :allow_same_account, %Account{id: 2}, %Account{id: 2}) ==
               true
    end
  end
end
