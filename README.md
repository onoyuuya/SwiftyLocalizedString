SwiftyLocalizedString
========

A tiny script to generate typed localized strings.


Example
--------

If you have this Localizable.strings:


### ja.lproj/Localizable.strings

```
"greetings" = "こんにちは";
"introduction" = "私は %d 歳です。";
```

### en.lproj/Localizable.strings

```
"greetings" = "Hello";
"introduction" = "I'm %d years old.";
```


You will get this struct LocalizedStrings.

```
struct LocalizedStrings {
    /// こんにちは
    static var greetings: String {
        return NSLocalizedString("greetings", comment: "")
    }

    /// 私は %d 歳です。
    static var introduction(_ value0: Int) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("introduction", comment: ""), value0)
    }
}
```


Usage
--------

```
$ ruby parse_strings.rb path/to/Localizable.strings path/to/output.swift
```

If your `Localizable.strings` is placed at `$SRCROOT/YourAwesomeApp/Resources/**.lproj/Localizable.strings`, you should pass `$SRCROOT/YourAwesomeApp/Resources/` into the first argument.


Restrictions
--------

This is tiny script :)

- `Localizable.strings` is only supported. Other tables cannot be used.
- Localizable.strings must be encoded by UTF-8, and be formatted like: `"key" = "value";`.
- `%d`(Int) and `%@`(String) are only supported for variables in strings.


LICENSE
--------
MIT
