defmodule Core.UserLogTest do
  use ExUnit.Case, async: true

  alias Core.UserLog

  describe "weekday/1" do
    test "an ISO date resolves to its weekday name" do
      assert UserLog.weekday("2026-07-19") == "Sunday"
    end

    test "an unparseable date renders as empty" do
      assert UserLog.weekday("nope") == ""
    end
  end

  describe "get_day/1" do
    test "a path-traversal key returns the empty day shape" do
      assert %{archived: [], conversations: [], dream: "", notes: "", weekday: ""} =
               UserLog.get_day("../../etc/passwd")
    end
  end
end
