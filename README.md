kindai.rb
=========

使い方
------

近代デジタルライブラリーから画像をダウンロードします．

使い方
------

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693

必要
----

* Rubyが必要です．
* Nokogiriが必要なので，RubyGemsで入れてください．

オプション
----------

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --output ~/Documents/

のように，--outputオプションで，保存先を指定できます．指定したディレクトリの下に，書名のディレクトリができます．
