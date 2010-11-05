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

 --outputオプションで，保存先を指定できます．指定したディレクトリの下に，書名のディレクトリができます．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --output ~/Documents/

 --retryオプションで，ダウンロードに失敗したとき何回やり直すかを指定できます．標準では3回ですが，回線が不安定な場合などは増やすとよいです．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --retry 10

 --divideオプションで，ダウンロードした画像を左右のページにトリミングします．ImageMagickが必要です．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --divide

 --resizeオプションで，ダウンロードした画像をリサイズします．ImageMagickが必要です．横600，縦800ピクセルにリサイズする場合は以下のように指定します．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --resize 600x800

 --pdfオプションで，ダウンロードした画像をまとめてPDFにします．Macのみ対応しています．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --pdf

 --zipオプションで，ダウンロードした画像をまとめてzipにします．zipコマンドが必要です．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --zip

 --trimming-オプションで，画像を指定した範囲でトリミングします．あらかじめ本の大きさをピクセル単位で調べておいて，余白を取り除くのに使えます．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 \
                   --trimming-x 330 --trimming-y 200 --trimming-width 2800 --trimming-height 2500
    もしくは
    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 -x 330 -y 200 -w 2800 -h 2500

 --testオプションで，最初の見開きだけをダウンロードします．これは，--trimmingオプションの引数を調整するのに便利です．

    ruby kindai.rb http://kindai.ndl.go.jp/info:ndljp/pid/922693 --test

おすすめ設定
------------

Kindleで読む場合は，以下のオプションを設定すると便利です．トリミングして，左右2分割して，zipを作ります．トリミング範囲(x,y,w,h)は，予め調べておく必要があります．

    ruby kindai.rb "http://kindai.da.ndl.go.jp/info:ndljp/pid/889675" \
         --output ~/Documents/kindai --divide --resize 600x800 --zip -x 320 -y 210 -w 2880 -h 2330

動作環境
--------

* Ruby が必要です．
* Nokogiri が必要なので，RubyGems でインストールしてください．
* Gemfile を書いてあるので，bundler が入ってる環境では bundle install コマンドを実行するだけで必要な Gem が入ります．
* 左右のページにトリミングする場合は，ImageMagickが必要です．ImageMagickがあるとき，画像が正しくダウンロードできたかどうかチェックするので，あると便利です．
[ImageMagick: Convert, Edit, and Compose Images](http://www.imagemagick.org/script/index.php)

その他
------
国立国会図書館デジタルアーカイブポータル（PORTA）外部提供インタフェースを利用しています．

[Wiki: 外部提供インタフェースについて](http://porta.ndl.go.jp/wiki/Wiki.jsp?page=%E5%A4%96%E9%83%A8%E6%8F%90%E4%BE%9B%E3%82%A4%E3%83%B3%E3%82%BF%E3%83%95%E3%82%A7%E3%83%BC%E3%82%B9%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6)
