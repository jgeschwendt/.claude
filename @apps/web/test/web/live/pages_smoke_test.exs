defmodule Web.PagesSmokeTest do
  use Web.ConnCase

  # Point the diary / memory / projects roots at fresh tmp dirs so these smoke tests
  # render against an empty world instead of the live ~/.claude tree (mirrors sweep_test).
  setup do
    base = Path.join(System.tmp_dir!(), "pages_smoke_#{System.unique_integer([:positive])}")
    memory = Path.join(base, "memory")
    projects = Path.join(base, "projects")
    diary = Path.join(base, "log")
    File.mkdir_p!(memory)
    File.mkdir_p!(projects)
    File.mkdir_p!(Path.join(diary, "archive"))
    Application.put_env(:web, :memory_root, memory)
    Application.put_env(:web, :projects_dir, projects)
    Application.put_env(:web, :diary_root, diary)

    on_exit(fn ->
      Application.delete_env(:web, :memory_root)
      Application.delete_env(:web, :projects_dir)
      Application.delete_env(:web, :diary_root)
      File.rm_rf!(base)
    end)

    :ok
  end

  test "GET /log", %{conn: conn} do
    assert html_response(get(conn, ~p"/log"), 200)
  end

  test "GET /memories", %{conn: conn} do
    assert html_response(get(conn, ~p"/memories"), 200)
  end

  # Reads the real ~/.claude/@routines + launchctl read-only — acceptable on this machine.
  test "GET /routines", %{conn: conn} do
    assert html_response(get(conn, ~p"/routines"), 200)
  end
end
