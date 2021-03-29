defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create a bank account" do
    assert :ok = ExBanking.create_user("account")
  end

  test "get balance" do
    account_name = "account"
    currency = "account"

    ExBanking.create_user(account_name)

    assert {:ok, 0} = ExBanking.get_balance(account_name, currency)
  end

  describe "deposit" do
    setup do
      account_name = "account"
      currency = "account"

      ExBanking.create_user(account_name)
      {:ok, account: account_name}
    end

    test "return new balance", %{account: account} do
      assert {:ok, 10000} = ExBanking.deposit(account, 10000, "USD")
      assert {:ok, 10000} = ExBanking.get_balance(account, "USD")
    end
  end
end
