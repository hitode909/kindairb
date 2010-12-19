kindai.rb
=========

概要
------

近代デジタルライブラリーから画像をダウンロードします．

使い方
------

起動時の引数に，ダウンロードしたい本の URL を指定します．スペース区切りで複数指定できます．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693

URL の代わりに検索ワードを指定すると，ヒットした本をまとめてダウンロードします．AND検索もできます．

    ruby kindai.rb 調理
    ruby kindai.rb "松茸 調理"

 --output オプションで，保存先を指定できます．指定したディレクトリの下に，書名のディレクトリができます．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --output ~/Documents/

 --retry オプションで，ダウンロードのリトライ回数を指定できます．標準では3回です．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --retry 10


本の加工(自動)
--------------

ダウンロードされた本は読みやすいように加工され， iPhone 用と Kindle 用のファイルが作られます．
以下のようなファイル構成になります．

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

- original/以下には加工前の画像が入ります．
- trim/以下にはトリミングして余白を取り除いた画像が入ります．パソコンで読むのに適しています．
- _iphone.zipは，iPhoneの画面サイズ(1280x960)にリサイズされた見開き画像のzipファイルです．Comic Glassで読むのに適しています．
- _kindle.zipは，Kindle3の画面サイズ(600x800)にリサイズされ，1ページずつに裁断された画像のzipファイルです．


本の加工(手動)
--------------

トリミング位置は自動的に決められますが，ダウンロード後に，ずれていることが分かった場合は，publish.rbを使ってトリミング位置を指定できます．

    ruby publish.rb --position 2905x2510+270+190 "~/Documents/正義熱血社 - 正義の叫"

幅2905ピクセル，高さ2510ピクセル，左の余白270ピクセル，上の余白190ピクセルでトリミングされます．

動作環境
--------

* Ruby が必要です．
* Nokogiri と RMagick が必要です，RubyGems でインストールしてください．
* Gemfile を書いてあるので，bundler が入ってる環境では bundle install コマンドを実行するだけで必要な Gem が入ります．

その他
------
国立国会図書館デジタルアーカイブポータル（PORTA）外部提供インタフェースを利用しています．

[Wiki: 外部提供インタフェースについて](http://porta.ndl.go.jp/wiki/Wiki.jsp?page=%E5%A4%96%E9%83%A8%E6%8F%90%E4%BE%9B%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%95%E3%82%A7%E3%83%BC%E3%82%B9%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)
