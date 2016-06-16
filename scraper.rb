#!/bin/env ruby
# encoding: utf-8

require 'colorize'
require 'csv'
require 'nokogiri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_term(id, url)
  noko = noko_for(url)
  noko.xpath('//table[.//th[.="Þingmaður"]]//tr[td]').each do |tr|
    tds = tr.css('td')
    area = id.to_i > 1990 ?  tr.xpath('preceding::h2/span[@class="mw-headline"]').last.text : tr.xpath('preceding::h4/span[@class="mw-headline"]').last.text 
    data = { 
      name: tds[2].css('a').text,
      wikiname: tds[2].xpath('.//a[not(@class="new")]/@title').text,
      party: tds[3].text.tidy,
      area: area.tidy,
      term: id,
      source: url,
    }
    # puts data
    ScraperWiki.save_sqlite([:name, :wikiname, :term], data)
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

terms.each do |id, url|
  scrape_term(id, url)
end
