#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.unshift('lib')
require 'kindai'

detail_url = ARGV.first || "http://kindai.ndl.go.jp/BIBibDetail.php?tpl_keyword_chg=%E5%88%9D%E7%AD%89&tpl_wid=WBPL110&tpl_wish_page_no=1&tpl_select_row_no=4&tpl_hit_num=483&tpl_bef_keyword=%E5%88%9D%E7%AD%89&tpl_action=&tpl_bib_access=1&tpl_search_kind=2&tpl_keyword=%E5%88%9D%E7%AD%89&tpl_sort_key=TITLE&tpl_sort_order=ASC&tpl_list_num=20&tpl_end_of_data="

book = Kindai::Book.new_from_detail_url(detail_url)

downloader = Kindai::Downloader.new_from_book(book)
Kindai::Util.logger.info "download #{book.title} to #{downloader.full_directory_path}"
downloader.download

