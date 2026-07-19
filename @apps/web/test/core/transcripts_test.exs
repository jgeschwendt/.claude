defmodule Core.TranscriptsTest do
  use ExUnit.Case, async: true

  alias Core.Transcripts

  setup do
    file =
      Path.join(System.tmp_dir!(), "transcripts_test_#{System.unique_integer([:positive])}.jsonl")

    on_exit(fn -> File.rm(file) end)
    %{fixture: file}
  end

  defp write_lines(file, objects) do
    File.write!(file, Enum.map_join(objects, "\n", &Jason.encode!/1))
  end

  test "consecutive user prefixes collapse to the final resubmission", %{fixture: file} do
    write_lines(file, [
      %{
        "type" => "user",
        "message" => %{"role" => "user", "content" => "Hello"},
        "timestamp" => "2026-07-19T10:00:00Z"
      },
      %{
        "type" => "user",
        "message" => %{"role" => "user", "content" => "Hello world"},
        "timestamp" => "2026-07-19T10:00:01Z"
      }
    ])

    session = Transcripts.parse_session(file, nil)

    assert session.message_count == 1
    assert [%{blocks: [%{kind: "text", text: "Hello world"}]}] = session.messages
  end

  test "a command-name message is meta and usage accumulates across assistants", %{fixture: file} do
    write_lines(file, [
      %{
        "type" => "user",
        "message" => %{"role" => "user", "content" => "<command-name>foo</command-name>"},
        "timestamp" => "2026-07-19T10:00:00Z"
      },
      %{
        "type" => "assistant",
        "message" => %{
          "role" => "assistant",
          "content" => [%{"type" => "text", "text" => "one"}],
          "usage" => %{"input_tokens" => 10, "output_tokens" => 5}
        },
        "timestamp" => "2026-07-19T10:00:01Z"
      },
      %{
        "type" => "assistant",
        "message" => %{
          "role" => "assistant",
          "content" => [%{"type" => "text", "text" => "two"}],
          "usage" => %{"input_tokens" => 3, "output_tokens" => 2}
        },
        "timestamp" => "2026-07-19T10:00:02Z"
      }
    ])

    session = Transcripts.parse_session(file, nil)

    # the command-name user message is meta → excluded from the count; two assistants remain
    assert session.message_count == 2
    assert session.tokens.input == 13
    assert session.tokens.output == 7
  end
end
