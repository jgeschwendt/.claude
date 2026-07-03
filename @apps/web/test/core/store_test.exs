defmodule Core.StoreTest do
  use ExUnit.Case, async: true

  describe "component?/1" do
    test "accepts plain filename segments" do
      assert Core.Store.component?("abc")
      assert Core.Store.component?("2026-07-03")
      assert Core.Store.component?("feedback_deploy_process.md")
      assert Core.Store.component?("-Users-jlg--claude")
    end

    test "rejects traversal, separators, and non-strings" do
      refute Core.Store.component?("..")
      refute Core.Store.component?(".")
      refute Core.Store.component?("")
      refute Core.Store.component?("../etc")
      refute Core.Store.component?("a/b")
      refute Core.Store.component?("a\0b")
      refute Core.Store.component?(nil)
      refute Core.Store.component?(123)
    end
  end

  test "write!/2 replaces atomically and leaves no temp files" do
    dir = Path.join(System.tmp_dir!(), "store_test_#{System.unique_integer([:positive])}")
    path = Path.join(dir, "f.json")
    Core.Store.write!(path, "one")
    Core.Store.write!(path, "two")
    assert File.read!(path) == "two"
    assert File.ls!(dir) == ["f.json"]
    File.rm_rf!(dir)
  end
end
