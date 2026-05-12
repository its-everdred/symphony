defmodule SymphonyElixir.Os.SttyRunner do
  @moduledoc false
  # Shared `System.cmd("stty", ...)` invocation; per-OS modules only build the
  # argv (GNU `-F` vs BSD `-f`) and delegate here.

  @spec run([String.t()]) :: :ok | {:error, String.t()}
  def run(args) do
    case System.cmd("stty", args, stderr_to_stdout: true) do
      {_output, 0} ->
        :ok

      {output, status} ->
        {:error, "stty #{Enum.join(args, " ")} exited with status #{status}: #{String.trim(output)}"}
    end
  rescue
    error in [ErlangError, System.EnvError] ->
      {:error, "stty invocation failed: #{Exception.message(error)}"}
  end
end
