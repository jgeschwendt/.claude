defmodule Core.GuardsTest do
  use ExUnit.Case, async: true

  # These traversal params must never reach a File operation outside the intended root;
  # the guarded Core entry points return an :error tuple (or nil) instead of acting.

  test "delete_session rejects a traversal project/id" do
    assert {:error, :invalid_path} = Core.Transcripts.delete_session("../../etc", "passwd")
    assert {:error, :invalid_path} = Core.Transcripts.delete_session("proj", "../../../x")
  end

  test "get_session returns nil for a traversal segment" do
    assert Core.Transcripts.get_session("..", "..") == nil
  end

  test "memory mutations reject non-writable/traversal banks" do
    assert {:error, :not_writable} =
             Core.Memory.commit_fact(%{
               bank: "../..",
               name: "x",
               type: "reference",
               body: "b",
               description: "d"
             })

    assert {:error, :not_writable} = Core.Memory.delete_fact("auto:whatever", "f.md")
    assert {:error, :not_writable} = Core.Memory.delete_fact("bank", "../../x")
  end

  test "write_notes rejects a non-date key" do
    assert {:error, :invalid_date} = Core.UserLog.write_notes("../../tmp/evil", "hi")
  end

  test "routine slug ops reject traversal slugs" do
    assert {:error, :invalid_slug} = Core.Routines.delete("../../../x")
    assert {:error, :invalid_slug} = Core.Routines.run_now("../../../x")
  end

  test "decode_project round-trips a hidden-dir cwd" do
    assert Core.Transcripts.decode_project("-Users-jlg--claude") == "/Users/jlg/.claude"
  end
end
