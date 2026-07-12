defmodule Core.Memory.SweepTest do
  use ExUnit.Case, async: false

  alias Core.Memory.Sweep

  # No fixture in this file may be BOTH quiescent and non-trivial — that combination
  # is the one that spends a real `claude` call.

  setup do
    base = Path.join(System.tmp_dir!(), "sweep_test_#{System.unique_integer([:positive])}")
    memory = Path.join(base, "memory")
    projects = Path.join(base, "projects")
    File.mkdir_p!(memory)
    File.mkdir_p!(projects)
    Application.put_env(:web, :memory_root, memory)
    Application.put_env(:web, :projects_dir, projects)

    on_exit(fn ->
      Application.delete_env(:web, :memory_root)
      Application.delete_env(:web, :projects_dir)
      File.rm_rf!(base)
    end)

    %{projects: projects}
  end

  defp write_session(projects, id, messages, at) do
    dir = Path.join(projects, "-tmp-proj")
    File.mkdir_p!(dir)

    lines =
      Enum.map(messages, fn text ->
        Jason.encode!(%{
          "type" => "user",
          "cwd" => "/tmp/proj",
          "timestamp" => at,
          "message" => %{"content" => text}
        })
      end)

    File.write!(Path.join(dir, id <> ".jsonl"), Enum.join(lines, "\n") <> "\n")
  end

  defp iso_hours_ago(h),
    do: DateTime.utc_now() |> DateTime.add(-h * 3600) |> DateTime.to_iso8601()

  test "fresh sessions are left alone", %{projects: projects} do
    write_session(
      projects,
      "fresh",
      ["did a thing", "and another", "and more", "and more"],
      iso_hours_ago(1)
    )

    report = Sweep.run()

    assert report.considered == 0
    assert report.results == []
    assert File.exists?(Path.join(projects, "-tmp-proj/fresh.jsonl"))
  end

  test "quiescent trivial sessions are ledgered without a claude call", %{projects: projects} do
    write_session(projects, "tiny", ["hi"], iso_hours_ago(72))

    report = Sweep.run()

    assert report.trivial == 1
    assert report.results == []
    # transcript is left in place — trivial sessions are skipped, not consumed
    assert File.exists?(Path.join(projects, "-tmp-proj/tiny.jsonl"))
    assert [%{"outcome" => "trivial", "id" => "tiny"}] = Sweep.recent()
  end

  test "a trivial verdict is idempotent until the session gains messages", %{projects: projects} do
    write_session(projects, "tiny", ["hi"], iso_hours_ago(72))

    assert Sweep.run().trivial == 1
    assert Sweep.run().trivial == 0

    # new activity (a changed updated_at) re-arms the session
    write_session(projects, "tiny", ["hi", "more"], iso_hours_ago(60))
    assert Sweep.run().trivial == 1
  end

  test "quiescent non-trivial sessions are due but capped by max: 0", %{projects: projects} do
    write_session(projects, "real", ["a", "b", "c", "d", "e"], iso_hours_ago(72))

    # max: 0 exercises the due path without spending a claude call
    report = Sweep.run(max: 0)

    assert report.considered == 1
    assert report.deferred == 1
    assert report.results == []
    assert File.exists?(Path.join(projects, "-tmp-proj/real.jsonl"))
  end
end
