defmodule SymphonyElixir.OsTest do
  use ExUnit.Case, async: false

  alias SymphonyElixir.Os
  alias SymphonyElixir.Os.Darwin

  setup do
    previous = Application.get_env(:symphony_elixir, :os_impl)
    on_exit(fn -> reset_impl(previous) end)
    :ok
  end

  defmodule FakeImpl do
    @behaviour SymphonyElixir.Os

    @impl true
    def tty_device, do: {:ok, "/dev/fake"}

    @impl true
    def stty(device, args), do: send(self(), {:stty, device, args}) && :ok
  end

  test "tty_device/0 delegates to the configured impl" do
    Application.put_env(:symphony_elixir, :os_impl, FakeImpl)
    assert {:ok, "/dev/fake"} = Os.tty_device()
  end

  test "stty/2 delegates to the configured impl" do
    Application.put_env(:symphony_elixir, :os_impl, FakeImpl)
    assert :ok = Os.stty("/dev/fake", ["-icanon", "-echo"])
    assert_received {:stty, "/dev/fake", ["-icanon", "-echo"]}
  end

  test "impl/0 selects Darwin on :darwin and Linux otherwise" do
    Application.delete_env(:symphony_elixir, :os_impl)

    expected =
      case :os.type() do
        {:unix, :darwin} -> Darwin
        _ -> SymphonyElixir.Os.Linux
      end

    assert Os.impl() == expected
  end

  test "impl/0 honors the application env override" do
    Application.put_env(:symphony_elixir, :os_impl, FakeImpl)
    assert Os.impl() == FakeImpl
  end

  describe "SymphonyElixir.Os.Darwin" do
    test "tty_device/0 returns /dev/tty" do
      assert {:ok, "/dev/tty"} = Darwin.tty_device()
    end
  end

  defp reset_impl(nil), do: Application.delete_env(:symphony_elixir, :os_impl)
  defp reset_impl(value), do: Application.put_env(:symphony_elixir, :os_impl, value)
end
