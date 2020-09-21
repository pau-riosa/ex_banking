defmodule ExBanking.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []
    :ets.new(:ex_banking, [:public, :named_table])
    opts = [strategy: :one_for_one, name: ExBanking.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
