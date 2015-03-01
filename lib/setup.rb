require 'base64'

class HerBasicAuth < Faraday::Middleware
  def call(env)
    header = "Basic #{Base64.encode64( [ENV['HER_USER'], ENV['HER_PASS'] ].join(':')).gsub("\n", '')}"
    env[:request_headers]["Authorization"] = header
    @app.call(env)
  end
end

Her::API.setup url: "https://cloud.skytap.com", send_only_modified_attributes: true do |c|
  c.use HerBasicAuth
  c.use Faraday::Request::UrlEncoded
  c.use Her::Middleware::AcceptJSON
  c.use Her::Middleware::DefaultParseJSON
  c.use Faraday::Adapter::NetHttp
end

