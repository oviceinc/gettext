defmodule Gettext.PO.TranslationsTest do
  use ExUnit.Case, async: true

  doctest Gettext.PO.Translations

  alias Gettext.PO.Translation
  alias Gettext.PO.PluralTranslation
  alias Gettext.PO.Translations

  @autogenerated_flags MapSet.new(["elixir-autogen"])

  test "autogenerated?/1: singular translations" do
    t = %Translation{msgid: "foo"}
    assert Translations.autogenerated?(%{t | flags: @autogenerated_flags})
    assert Translations.autogenerated?(%{t | flags: MapSet.new(["elixir-format"])})
    refute Translations.autogenerated?(t)
  end

  test "autogenerated?/1: plural translations" do
    t = %PluralTranslation{msgid: "foo", msgid_plural: "foos"}
    assert Translations.autogenerated?(%{t | flags: @autogenerated_flags})
    refute Translations.autogenerated?(t)
  end

  test "same?/2: singular translations" do
    t1 = %Translation{msgid: "foo", msgstr: "a"}
    t2 = %Translation{msgid: "foo", msgstr: "b"}
    assert Translations.same?(t1, t2)

    refute Translations.same?(%Translation{msgid: "a"}, %Translation{msgid: "b"})
  end

  test "same?/2: plural translations" do
    assert Translations.same?(
             %PluralTranslation{msgid: "foo", msgid_plural: "bar", references: [{"foo.ex", 1}]},
             %PluralTranslation{msgid: "foo", msgid_plural: "bar"}
           )

    refute Translations.same?(
             %PluralTranslation{msgid: "a", msgid_plural: "foo"},
             %PluralTranslation{msgid: "b", msgid_plural: "foo"}
           )

    refute Translations.same?(
             %PluralTranslation{msgid: "foo", msgid_plural: "a"},
             %PluralTranslation{msgid: "foo", msgid_plural: "b"}
           )
  end

  test "same?/2: mixed singular and plural translations (always different)" do
    refute Translations.same?(%Translation{msgid: "a"}, %PluralTranslation{
             msgid: "a",
             msgid_plural: "as"
           })
  end

  test "same?/2: ignores if msgids are split as long as they're equal when concatenated" do
    assert Translations.same?(%Translation{msgid: ["foo", " bar"]}, %Translation{
             msgid: ["foo ", "bar"]
           })

    assert Translations.same?(
             %PluralTranslation{msgid: ["ab", "c"], msgid_plural: ["de", "f"]},
             %PluralTranslation{msgid: ["a", "bc"], msgid_plural: ["d", "ef"]}
           )
  end

  test "mark_as_fuzzy/1" do
    t = Translations.mark_as_fuzzy(%Translation{msgid: "foo"})
    assert MapSet.member?(t.flags, "fuzzy")

    t = Translations.mark_as_fuzzy(%PluralTranslation{msgid: "foo", msgid_plural: "foos"})
    assert MapSet.member?(t.flags, "fuzzy")
  end
end
