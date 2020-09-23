defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """
  alias ExBanking.User

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
         {false, amount} <- is_negative?(amount),
         deposit_money <- compute_money(state, amount, currency),
         {:ok, new_balance} <- Money.add(state.money, deposit_money) do
      new_state = %{state | money: new_balance}
      :ets.insert(:ex_banking, {name, new_state})
      {:ok, new_balance.amount}
    else
      [] -> {:error, :user_does_not_exist}
      _error -> {:error, :wrong_arguments}
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
         {false, amount} <- is_negative?(amount),
         withdraw_money <- compute_money(state, amount, currency),
         :gt <-
           Money.compare(state.money, withdraw_money),
         {:ok, new_balance} <- Money.sub(state.money, withdraw_money) do
      new_state = %{state | money: Money.abs(new_balance)}
      :ets.insert(:ex_banking, {name, new_state})
      {:ok, Money.abs(new_balance).amount}
    else
      :eq -> {:error, :not_enough_money}
      :lt -> {:error, :not_enough_money}
      [] -> {:error, :user_does_not_exist}
      _error -> {:error, :wrong_arguments}
    end
  end

  @doc """
  * Returns BALANCE of the user in given format
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
    with [{key, state}] <- lookup(user),
         {:ok, current_money} <- state.money |> Money.to_currency(currency),
         current_money <- current_money |> Money.round() do
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
    with {{:ok, _amount}, :sender} <- {withdraw(from_user, amount, currency), :sender},
         {{:ok, _amount}, :receiver} <- {deposit(to_user, amount, currency), :receiver},
         {:ok, from_user_balance} <- get_balance(from_user, currency),
         {:ok, to_user_balance} <- get_balance(to_user, currency) do
      {:ok, from_user_balance, to_user_balance}
    else
      {{:error, :not_enough_money}, :sender} -> {:error, :not_enough_money}
      {{:error, :not_enough_money}, :receiver} -> {:error, :not_enough_money}
      {{:error, :user_does_not_exist}, :sender} -> {:error, :sender_does_not_exist}
      {{:error, :user_does_not_exist}, :receiver} -> {:error, :receiver_does_not_exist}
      error -> error
    end
  end

  def lookup(user) do
    :ets.lookup(:ex_banking, String.to_atom(user))
  end

  defp is_negative?(amount) do
    amount = Decimal.new(amount)
    {false, amount} = {Decimal.negative?(amount), amount}
  end

  defp compute_money(state, amount, currency) do
    {:ok, withdraw_money} = Money.new(currency, amount) |> Money.to_currency(state.money.currency)
    withdraw_money |> Money.round()
  end
end
