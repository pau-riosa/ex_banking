defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """
  alias ExBanking.Account

  use Agent

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
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) do
    {:ok, account} = Agent.start(fn -> Account.account(user) end, name: String.to_atom(user))
    :ok
  end

  @doc """
  * Increases user's balance in given CURRENCY by AMOUNT value 
  * Returns NEW_BALANCE of the user in given format
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    Agent.get_and_update(String.to_atom(user), fn state ->
      new_balance = state.balance + amount
      new_state = %{state | balance: new_balance, currency: currency}
      {{:ok, new_balance}, new_state}
    end)
  end

  @doc """
  * Decreases user's balance in given CURRENCY by AMOUNT VALUE 
  * Returns NEW_BALANCE of the user in given format
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
  end

  @doc """
  * Returns BALANCE of the user in given format
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    with atom <- String.to_atom(user),
         pid <- Process.whereis(atom) do
      Agent.get_and_update(atom, fn state ->
        new_state = %{state | requests: state.requests + 1}
        {{:ok, new_state.balance}, new_state}
      end)
    else
      nil ->
        {:error, :user_does_not_exist}
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
  end
end
