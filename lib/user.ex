defmodule ExBanking.Account do
  alias __MODULE__
  defstruct name: nil, balance: 0, requests: 0, currency: ""

  def account(user), do: %Account{name: user}
end
