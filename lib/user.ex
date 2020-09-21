defmodule ExBanking.User do
  alias __MODULE__
  defstruct user: nil, money: Money.new(0, :USD), balance: 0, requests: 0

  def add_user(user), do: {:ok, %User{user: user}}
end
