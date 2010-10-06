kindai.rb
=========

概要
------

近代デジタルライブラリーから画像をダウンロードします．

使い方
------

起動時の引数に，ダウンロードしたい本の URL を指定します．スペース区切りで複数指定できます．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693

URLの代わりに検索ワードを指定すると，ヒットした本をまとめてダウンロードします．

    ruby kindai.rb 調理

複数のキーワードで AND 検索を行うには，以下のように，キーワードを" "で囲みます．

    ruby kindai.rb "松茸 調理"

以下のように，--outputオプションで，保存先を指定できます．指定したディレクトリの下に，書名のディレクトリができます．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --output ~/Documents/

動作環境
--------

* Ruby が必要です．
* Nokogiri が必要なので，RubyGems でインストールしてください．
* Gemfile を書いてあるので，bundler が入ってる環境では bundle install コマンドを実行するだけで必要な Gem が入ります．

その他
------
国立国会図書館デジタルアーカイブポータル（PORTA）外部提供インタフェースを利用しています．
[Wiki: 外部提供インタフェースについて](http://porta.ndl.go.jp/wiki/Wiki.jsp?page=%E5%A4%96%E9%83%A8%E6%8F%90%E4%BE%9B%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%95%E3%82%A7%E3%83%BC%E3%82%B9%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6#%E5%A4%96%E9%83%A8%E6%8F%90%E4%BE%9B%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%95%E3%82%A7%E3%83%BC%E3%82%B9%E4%BB%95%E6%A7%98%E3%81%AB%E9%96%A2%E3%81%99%E3%82%8B%E8%B3%87%E6%96%99)
