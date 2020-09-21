defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """
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
    IO.inspect(:create_user)
  end

  @doc """
  * Increases user's balance in given CURRENCY by AMOUNT value 
  * Returns NEW_BALANCE of the user in given format
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    IO.inspect(:deposit)
  end

  @doc """
  * Decreases user's balance in given CURRENCY by AMOUNT VALUE 
  * Returns NEW_BALANCE of the user in given format
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
    IO.inspect(:withdraw)
  end

  @doc """
  * Returns BALANCE of the user in given format
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  def get_balance(user, amount, currency) do
    IO.inspect(:get_balance)
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
end
