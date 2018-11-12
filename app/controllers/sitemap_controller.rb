class SitemapController < ApplicationController
  class Sitemap
    def initialize(entries = [])
      @entries = entries
    end

    def <<(entry)
      # loc:
      # lastmod: YYYY-MM-DD
      # changefreq: always|hourly|daily|weekly|monthly|yearly|never
      # priority: default 0.5

      @entries << entry
    end

    def to_xml(args)
      "<?xml version='1.0' encoding='UTF-8'?>\n" \
      + "<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'>\n" \
      + @entries.collect {|entry|
        "  <url>" \
        + "   <loc>#{entry[:loc]}</loc>" \
        + (entry[:lastmod] ? "<lastmod>#{entry[:lastmod]}</lastmod>" : "") \
        + (entry[:changefreq] ? "<changefreq>#{entry[:changefreq]}</changefreq>" : "") \
        + (entry[:priority] ? "<priority>#{entry[:priority]}</priority>" : "") \
        + "  </url>\n"
      }.join \
      + "</urlset>\n"
    end
  end

  def sitemap
    @sitemap = Sitemap.new

    @sitemap << {loc: "https://kithward.com/", changefreq: 'daily', priority: 1.0}
    @sitemap << {loc: "https://kithward.com/learn", changefreq: 'daily', priority: 1.0}
    @sitemap << {loc: "https://kithward.com/thrive", changefreq: 'daily', priority: 1.0}

    Community.active.care_type_il.find_each do |community|
      @sitemap << {
        loc: "https://kithward.com/community/#{community.slug}",
        lastmod: community.updated_at.strftime("%F"),
        changefreq: 'weekly',
        priority: 0.7
      }
    end

    GeoPlace.find_each do |geo|
      @sitemap << {
        loc: "https://kithward.com/independent-living/near-#{geo.slug}",
        changefreq: 'weekly',
        priority: 0.8,
      }
    end

    render xml: @sitemap
  end
end
