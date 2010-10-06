kindai.rb
=========

概要
------

近代デジタルライブラリーから画像をダウンロードします．

使い方
------

起動時の引数に，ダウンロードしたい本のURLを指定します．スペース区切りで複数指定できます．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693

検索ワードを指定して根刮ぎ取ってきたい場合は

    ruby nekosogi.rb "死 糞"

のようにすることが出来ます.

必要
----

* Rubyが必要です．
* Nokogiriが必要なので，RubyGemsで入れてください．

オプション
----------

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --output ~/Documents/

のように，--outputオプションで，保存先を指定できます．指定したディレクトリの下に，書名のディレクトリができます．
