require 'test_helper'
require 'ostruct'

describe VersionableApi::ApiVersioning do
  class Testable 
    include VersionableApi::ApiVersioning
    attr_accessor :request
    def initialize
      @request = OpenStruct.new
      @request.headers = {}
    end
  end

  before do 
    @test_me = Testable.new
  end

  it "should have a default version of 1" do 
    assert_equal 1, @test_me.default_version
  end

  describe "#requested_version" do 
    it "should determine the requested version from the request headers" do 
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=10"
      assert_equal 10, @test_me.requested_version
    end

    it "should return nil if no explicit version is requested" do 
      assert_nil @test_me.requested_version
    end

    it "should return nil if the version requested is non-numeric" do 
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=FOO"
      assert_nil @test_me.requested_version
    end
  end

  describe "#method_for_action" do 
    before do 
      def @test_me.show_v1; 1; end;
      def @test_me.show_v2; 2; end;
      def @test_me.index_v1; 1; end;
    end

    it "should return the default version when no version is requested" do 
      assert_equal "show_v1", @test_me.method_for_action("show")
    end

    it "should return the requested version if specified and available" do 
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=2"
      assert_equal "show_v2", @test_me.method_for_action("show")
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=1"
      assert_equal "show_v1", @test_me.method_for_action("show")
    end

    it "should return the highest available version if the version specified is higher than the available versions" do 
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=10"
      assert_equal "show_v2", @test_me.method_for_action("show")
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=2"
      assert_equal "index_v1", @test_me.method_for_action("index")
    end

    it "should return _handle_action_missing if #action_missing is defined and unkown action is called for" do 
      def @test_me.action_missing; true; end;
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=2"
      assert_equal "_handle_action_missing", @test_me.method_for_action("foobar")
    end

    it "should return nil if #action_missing is not defined and an unkown action is specified" do 
      @test_me.request.headers["HTTP_ACCEPT"] = "*/*;version=2"
      assert_nil @test_me.method_for_action("foobar")
    end
  end
end
