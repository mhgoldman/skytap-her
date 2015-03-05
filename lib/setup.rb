require 'base64'

class HerBasicAuth < Faraday::Middleware
  def call(env)
    header = "Basic #{Base64.encode64( [ENV['HER_USER'], ENV['HER_PASS'] ].join(':')).gsub("\n", '')}"
    env[:request_headers]["Authorization"] = header
    @app.call(env)
  end
end

# class DebugMW < Faraday::Middleware
#   def call(env)
#     puts "HERE IS THE OUTPUT:"
#     puts env.to_s
#     @app.call(env).on_complete do |new_env|
#       puts "DONEZO! #{new_env}"
#     end
#   end
# end

Her::API.setup url: "https://cloud.skytap.com", send_only_modified_attributes: true do |c|
  c.use HerBasicAuth
  # c.use DebugMW
  c.use Faraday::Request::UrlEncoded
  c.use Her::Middleware::AcceptJSON
  c.use Her::Middleware::DefaultParseJSON
  c.use Faraday::Adapter::NetHttp
end

