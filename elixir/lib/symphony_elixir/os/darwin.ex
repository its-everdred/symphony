defmodule SymphonyElixir.Os.Darwin do
  @moduledoc """
  macOS implementation of the `SymphonyElixir.Os` behaviour.

  macOS has no procfs, so the controlling tty is read from `/dev/tty`
  directly (the Unix-standard controlling-terminal special file). BSD `stty`
  uses the lowercase `-f` device flag.
  """

  @behaviour SymphonyElixir.Os

  alias SymphonyElixir.Os.SttyRunner

  @impl true
  def tty_device, do: {:ok, "/dev/tty"}

  @impl true
  def stty(device, args), do: SttyRunner.run(["-f", device | args])
end
