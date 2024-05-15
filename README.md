# eikana
<div align="center">
<img src="https://raw.githubusercontent.com/KS1019/eikana/main/eikana/Assets.xcassets/AppIcon.appiconset/icon@0.5.png" width=300>
</div>

eikana はコマンドキーを利用して英語入力とかな入力を切り替えられるヘルパーアプリです。USキーボードでJISキーボードに近い体験を得ることができます。

## インストール

1. Gitでクローン

```sh
git clone 
```

2. ビルド

```sh
cd eikana/Scripts && swift Build.swift
```

3. インストール

```sh
swift Install.swift
```

## 仕組み

- `NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged, .keyDown], handler:)` という関数を呼ぶことでキーの押し込み状態を監視しています。

- `CGEvent(keyboardEventSource:)` を利用してかな入力キーもしくは英数入力キーを擬似的に入力しています。

## 他のツール

- [iMasanari/cmd-eikana: Application of macOS which switches Alphabet / Kana by pressing left and right command key alone. Other key remapping is also possible.](https://github.com/iMasanari/cmd-eikana)
