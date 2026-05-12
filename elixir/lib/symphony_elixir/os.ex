defmodule SymphonyElixir.Os do
  @moduledoc """
  Platform abstraction for OS-specific runtime operations (tty resolution,
  `stty` invocation). The dispatcher (`impl/0`) picks an implementation based
  on `:os.type/0` and can be overridden in tests via the
  `:symphony_elixir, :os_impl` application env.

  Callers should always go through `SymphonyElixir.Os.tty_device/0` and
  `SymphonyElixir.Os.stty/2` — never re-detect the OS inline.
  """

  @callback tty_device() :: {:ok, String.t()} | {:error, term()}
  @callback stty(device :: String.t(), args :: [String.t()]) :: :ok | {:error, term()}

  @spec impl() :: module()
  def impl do
    Application.get_env(:symphony_elixir, :os_impl) || default_impl()
  end

  @spec tty_device() :: {:ok, String.t()} | {:error, term()}
  def tty_device, do: impl().tty_device()

  @spec stty(String.t(), [String.t()]) :: :ok | {:error, term()}
  def stty(device, args), do: impl().stty(device, args)

  defp default_impl do
    case :os.type() do
      {:unix, :darwin} -> __MODULE__.Darwin
      _ -> __MODULE__.Linux
    end
  end
end
