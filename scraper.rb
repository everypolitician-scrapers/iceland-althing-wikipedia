#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_term(id, url)
  noko = noko_for(url)
  noko.xpath('//table[.//th[contains(.,"Þingmaður")]]//tr[td]').each do |tr|
    tds = tr.css('td')
    area = id.to_i > 1990 ? tr.xpath('preceding::h2/span[@class="mw-headline"]').last.text : tr.xpath('preceding::h4/span[@class="mw-headline"]').last.text
    data = {
      name:     tds[2].css('a').text,
      wikiname: tds[2].xpath('.//a[not(@class="new")]/@title').text,
      party:    tds[3].text.tidy,
      area:     area.tidy,
      term:     id,
      source:   url,
    }
    # puts data
    ScraperWiki.save_sqlite(%i(name wikiname term), data)
  end
end

terms = {
  '2013' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_2013',
  '2009' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_2009',
  '2007' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_2007',
  '2003' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_2003',
  '1999' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_1999',
  '1995' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_1995',
  # '1991' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_1991'
  # '1987' => 'https://is.wikipedia.org/wiki/Kj%C3%B6rnir_al%C3%BEingismenn_1987',
}

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
terms.each do |id, url|
  scrape_term(id, url)
end
