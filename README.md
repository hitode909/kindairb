# kindai.rb [![Build Status](https://travis-ci.org/hitode909/kindairb.png?branch=master)](https://travis-ci.org/hitode909/kindairb)

## 近デジダウンローダー

国立国会図書館デジタルコレクションから画像をダウンロードします．

```
gem install kindai
```

## 使い方

gemをインストールすると，kindai.rbというコマンドがインストールされます．

起動時の引数に，ダウンロードしたい本の URL を指定します．スペース区切りで複数指定できます．

```
kindai.rb http://dl.ndl.go.jp/info:ndljp/pid/922693
```

URL の代わりに検索ワードを指定すると，ヒットした本をまとめてダウンロードします．AND検索もできます．

```
kindai.rb 調理
kindai.rb "松茸 調理"
```

--output オプションで，保存先を指定できます．指定したディレクトリの下に，書名のディレクトリができます．

```
kindai.rb http://dl.ndl.go.jp/info:ndljp/pid/922693 --output ~/Documents/
```

## 本の加工(自動)

ダウンロードした本は自動的にトリミングされ，trim/ディレクトリに格納されます．トリミング情報は自動的に共有され，次に同じ本をダウンロードしたときや，他のひとが同じ本をダウンロードしたときに再利用されます．

起動時の引数で，ダウンロードした本を iPhone 用と Kindle 用に加工することができます．

 --publish_iphone オプションで，iPhone用のファイルを作ります．
 --publish_kindle オプションで，Kindle用のファイルを作ります．

両方指定すると，以下のようなファイル構成になります．

```
正義熱血社 - 正義の叫
├── original
│   ├── 001.jpg
│   ├── 002.jpg
│   ├── 003.jpg
(中略)
│   └── 020.jpg
├── trim
│   ├── 001.jpg
│   ├── 002.jpg
│   ├── 003.jpg
(中略)
│   └── 020.jpg
├── 正義熱血社 - 正義の叫_iphone.zip
└── 正義熱血社 - 正義の叫_kindle.zip
```

- original/以下には加工前の画像が入ります．
- trim/以下にはトリミングして余白を取り除いた画像が入ります．パソコンで読むのに適しています．
- _iphone.zipは，iPhoneの画面サイズ(1280x960)にリサイズされた見開き画像のzipファイルです．Comic Glassで読むのに適しています．
- _kindle.zipは，Kindle3の画面サイズ(600x800)にリサイズされ，1ページずつに裁断された画像のzipファイルです．

 --no_trimmingオプションが指定されたときは，ダウンロードだけを行い，トリミングや加工を行いません．

## 本の加工(手動)

トリミング位置は自動的に決められますが，ダウンロード後に，ずれていることが分かった場合は，kindai.rb publishを使ってトリミング位置を指定できます．

```
kindai.rb publish --position 2905x2510+270+190 "~/Documents/正義熱血社 - 正義の叫"
```

幅2905ピクセル，高さ2510ピクセル，左の余白270ピクセル，上の余白190ピクセルでトリミングされます．

## インストール

直接動かすことに加え，Dockerを使って動かすこともできます．

### 直接動かす場合

ライブラリのインストールなどで失敗するかもしれません．

- Rubyが必要です．
- RMagickを使っているので，ImageMagickが必要です．
 - Homebrewを使っている場合は以下のような雰囲気

```
brew install ruby imagemagick
```

これらの準備したのちに，RubyGemsからインストールできます．

```
gem install kindai
```

### Dockerで動かす場合

[Docker](https://www.docker.com/)のセットアップをしたのちに以下のコマンドで実行できます．
Dockerの仮想環境上で実行されるので，ライブラリのセットアップで苦労することがありません．

```
docker run --rm --volume "$PWD":/workdir hitode909/kindairb
```

例：本のダウンロード
```
docker run --rm --volume "$PWD":/workdir hitode909/kindairb http://kindai.ndl.go.jp/info:ndljp/pid/922693
```

Docker経由で実行するときには`--output`オプションは利用できません．
`/workdir`に本をダウンロードするので，DockerのVolume機能を使って都合のよいディレクトリを`/workdir`にマウントしてください．．

## 歴史

国立国会図書館デジタルコレクションは，その昔，近代デジタルライブラリーでした．

## Copyright

Copyright (c) 2011 hitode909. See LICENSE.txt for
further details.
