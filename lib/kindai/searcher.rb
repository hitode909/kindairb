# -*- coding: utf-8 -*-
module Kindai
  class Searcher
    def self.search str
      ary = []
      html = Nokogiri::HTML open("http://kindai.ndl.go.jp/BIBibList.php?tpl_action=KEYWORD&tpl_bef_keyword=#{CGI.escape str}&tpl_bib_access=1&tpl_end_of_data=&tpl_hit_num=20&tpl_keyword=#{CGI.escape str}&tpl_keyword_chg=#{CGI.escape str}&tpl_list_num=20&tpl_list_num_chg=20&tpl_search_kind=2&tpl_select_row_no=&tpl_sort_key=TITLE&tpl_sort_key_chg=TITLE&tpl_sort_order=ASC&tpl_sort_order_chg=ASC&tpl_wid=WBPL110&tpl_wish_page_no=1")
      table = html.xpath("//table[(@class='space_bottom10')]")
      table.first.children.to_ary.each do |tr| 
        ary << tr.children.to_ary.first.children.to_ary[1].attributes["href"].value.split("'")[3]
      end
      p ary
      links = []
      (1..ary.size).each do |z|
        html = Nokogiri::HTML open("http://kindai.ndl.go.jp/BIBibDetail.php?JP_NUM=43029521&KOMA=&VOL_NUM=&tpl_bib_access=1&tpl_end_of_data=&tpl_hit_num=6&tpl_jp_num=#{ary[z-1]}&tpl_keyword=#{CGI.escape str}&tpl_list_num=20&tpl_search_kind=2&tpl_select_row_no=#{z}&tpl_sort_key=TITLE&tpl_sort_order=ASC&tpl_toc_word=#{CGI.escape str}&tpl_vol_num=&tpl_wid=WBPD120&tpl_wish_page_no=1")
        link = html.xpath("//table[(@class='space_bottom30')]").first.children.to_ary.first.children.to_ary[5].children.to_ary[1].attributes["href"].value.split("'")[3]
        puts link
        links << "http://kindai.ndl.go.jp/#{link}"
      end
      return links
    end
  end
end
