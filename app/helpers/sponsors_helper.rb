# app/helpers/sponsors_helper.rb
module SponsorsHelper
  require 'uri'

  # Return a normalized URL string (http/https) or nil if invalid
  def normalized_website_url(website)
    return nil if website.blank?

    candidate = website.strip
    # If scheme missing, assume http
    candidate = "http://#{candidate}" unless candidate =~ %r{\A[a-z][a-z0-9+\-.]*://}i
    begin
      uri = URI.parse(candidate)
      return nil unless %w[http https].include?(uri.scheme)

      uri.to_s
    rescue URI::InvalidURIError
      nil
    end
  end

  # Render a safe link or escaped text when invalid
  def sponsor_website_link(website)
    url = normalized_website_url(website)
    if url
      link_to website, url, target: '_blank', rel: 'noopener noreferrer'
    else
      # show the raw/escaped value if present, otherwise nil
      website.present? ? h(website) : nil
    end
  end
end
