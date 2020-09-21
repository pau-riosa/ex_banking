defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """
  alias ExBanking.User
  require Logger

  @type banking_error ::
          {:error,
           :wrong_arguments
           | :user_already_exist
           | :user_does_not_exist
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :too_many_requests_to_sender
           | :too_many_requests_to_receiver}

  @doc """
  * Function creates a new user in the system
  * New user has zero balance of any currency
  """
  @spec create_user(user :: String.t()) :: :ok | banking_error
  def create_user(user) do
    with [] <- lookup(user),
         {:ok, created_user} <- User.add_user(user) do
      :ets.insert(:ex_banking, {String.to_atom(user), created_user})
      :ok
    else
      [_ | _] -> {:error, :user_already_exist}
    end
  end

  @doc """
  * Increases user's balance in given CURRENCY by AMOUNT value 
  * Returns NEW_BALANCE of the user in given format
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    with [{name, state}] <- lookup(user),
         {:ok, cross_rate} <- Money.cross_rate(state.money, currency),
         {:ok, deposit_money} <- Money.mult(Money.new(state.money.currency, 1), cross_rate),
         {:ok, current_money} <- Money.add(state.money, deposit_money) do
      new_state = %{state | money: current_money}
      :ets.insert(:ex_banking, {name, new_state})
      {:ok, current_money.amount}
    else
      _ -> {:error, :user_does_not_exist}
    end
  end

  @doc """
  * Decreases user's balance in given CURRENCY by AMOUNT VALUE 
  * Returns NEW_BALANCE of the user in given format
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
    with [{name, state}] <- lookup(user),
         {:ok, cross_rate} <- Money.cross_rate(state.money, currency),
         {:ok, withdraw_money} <- Money.mult(Money.new(state.money.currency, 1), cross_rate),
         :gt <-
           Money.compare(state.money, Money.new(state.money.currency, 0)),
         {:ok, current_money} <- Money.sub(state.money, withdraw_money) do
      new_state = %{state | money: Money.abs(current_money)}
      :ets.insert(:ex_banking, {name, new_state})
      {:ok, Money.abs(current_money).amount}
    else
      :eq -> {:error, :not_enough_money}
      _ -> {:error, :user_does_not_exist}
    end
  end

  @doc """
  * Returns BALANCE of the user in given format
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
    with [{key, state}] <- lookup(user),
         {:ok, cross_rate} <- Money.cross_rate(state.money, currency),
         {:ok, current_money} <- Money.mult(state.money, cross_rate) do
      {:ok, current_money}
    else
      [] -> {:error, :user_does_not_exist}
    end
  end

  @doc """
  * Decreases FROM_USER's balance in given CURRENCY by AMOUNT value
  * Increases TO_USER's balance in given CURRENCY by AMOUNT value
  * Returns BALANCE of FROM_USER and TO_USER in given format
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error

  def send(from_user, to_user, amount, currency) do
    IO.inspect(:send)
  end

  def lookup(user) do
    :ets.lookup(:ex_banking, String.to_atom(user))
  end
end
