require 'test_helper'

describe VersionableApi::ApiVersionInterceptor do
  describe "With defaults" do 
    before do 
      @app = MiniTest::Mock.new
      @test_me = VersionableApi::ApiVersionInterceptor.new(@app)
    end

    it "should forward the request to the next app as-is if it doesn't match the default API path setup" do 
      env = {"PATH_INFO" => "/something/foo.json", "HTTP_ACCEPT" => "*/*"}
      @app.expect :call, true, [env]
      @test_me.call(env)
      @app.verify
    end

    it "should change an old API path to a new path with version specified in the header" do 
      in_env = {"PATH_INFO" => "/api/v3/foo.json", "HTTP_ACCEPT" => "*/*"}
      expected_env = {"PATH_INFO" => "/api/foo.json", "HTTP_ACCEPT" => "*/*;version=3, */*"}
      @app.expect :call, true, [expected_env]
      @test_me.call(in_env)
      @app.verify
    end

    it "should not modify 'new' style API requests" do 
      env = {"PATH_INFO" => "/api/foo.json", "HTTP_ACCEPT" => "*/*;version=3"}
      @app.expect :call, true, [env]
      @test_me.call(env)
      @app.verify
    end
  end

  describe "With modified options" do 
    before do 
      @app = MiniTest::Mock.new
    end
    
    it "should allow a user to specify the regular expression used to identify API requests" do 
      @test_me = VersionableApi::ApiVersionInterceptor.new(@app, {version_regex: /version_(?<version>\d+)\/(?<path>.+)/})
      in_env = {"PATH_INFO" => "/version_3/foo.json", "HTTP_ACCEPT" => "*/*"}
      expected_env = {"PATH_INFO" => "/api/foo.json", "HTTP_ACCEPT" => "*/*;version=3, */*"}
      @app.expect :call, true, [expected_env]
      @test_me.call(in_env)
      @app.verify
    end

    it "should allow a user to specify old-stype API structure, new path and accept header structure" do 
      @test_me = VersionableApi::ApiVersionInterceptor.new(@app, {version_regex: /version_(?<version>\d+)\/(?<path>.+)/, api_prefix: "/get_data", accept_header: "*/*;v="})
      in_env = {"PATH_INFO" => "/version_3/foo.json", "HTTP_ACCEPT" => "*/*"}
      expected_env = {"PATH_INFO" => "/get_data/foo.json", "HTTP_ACCEPT" => "*/*;v=3, */*"}
      @app.expect :call, true, [expected_env]
      @test_me.call(in_env)
      @app.verify
    end
  end
end
