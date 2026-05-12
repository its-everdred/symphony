defmodule SymphonyElixir.Os.Linux do
  @moduledoc """
  Linux implementation of the `SymphonyElixir.Os` behaviour.

  Resolves the controlling tty via `/proc/self/fd/0` (procfs) and invokes
  GNU `stty` with the `-F` device flag.
  """

  @behaviour SymphonyElixir.Os

  alias SymphonyElixir.Os.SttyRunner

  @impl true
  def tty_device do
    case File.read_link("/proc/self/fd/0") do
      {:ok, "/dev/" <> _ = path} -> {:ok, path}
      {:ok, path} -> {:error, "stdin is not a tty (#{path})"}
      {:error, reason} -> {:error, "could not resolve controlling tty: #{inspect(reason)}"}
    end
  end

  @impl true
  def stty(device, args), do: SttyRunner.run(["-F", device | args])
end
