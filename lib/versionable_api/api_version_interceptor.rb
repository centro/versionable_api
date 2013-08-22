# Public: Rack Middleware for massaging URIs with the version in the path into
# bare resource URIs with the version specified in an Accept header.
module VersionableApi
  class ApiVersionInterceptor
    
    # Public: Initialize the ApiVersionInterceptor
    #
    # app - Next Rack middleware app in the chain
    # options - Options hash with these keys:
    #   version_regex - Regular Expression that matches API requests in the "old"
    #     format, should contain two named captures:
    #       1. 'version' - The version number
    #       2. 'path' - The API endpoint path
    #   api_prefix - Prefix for resulting URIs, the API endpoint path from the matcher
    #     will be appended to this to build the "real" uri
    #   accept_header - The accept header that will have the version appended to it and
    #     then will be prepended to the existing Accept headers on the request
    #
    # Example:
    #   Incoming URI we want to massage: "/api/v1/thing.json"
    #   Resulting URI we want to handle: "/api/thing.json", Accept Header: "*/*;version=1"
    #
    #   version_regex = /^\/api\/v(?<version>\d+)\/(?<path>.+)/
    #   api_prefix = "/api"
    #   accept_header = "*/*;version="
    #
    def initialize(app, options={})
      options = {
        version_regex: /^\/api\/v(?<version>\d+)\/(?<path>.+)/,
        api_prefix: "/api",
        accept_header: "*/*;version="
      }.merge(options)

      @app = app
      @version_regex = options[:version_regex]
      @api_prefix = options[:api_prefix]
      @accept_header = options[:accept_header]
    end
    
    def call(env)
      if m = env["PATH_INFO"].match(@version_regex)
        env["PATH_INFO"] = "#{@api_prefix}/#{m[:path]}"
        env["HTTP_ACCEPT"] = "#{@accept_header}#{m[:version]}, #{env['HTTP_ACCEPT']}"
      end
      @app.call env
    end
  end
end
