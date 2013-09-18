module VersionableApi
  module ApiVersioning

    # Public: The default version. Classes including ApiVersioning should specify
    # this themselves if they don't want the default version to be 1.  If you would
    # like to force the caller to specify a version in their request, override
    # this method have have it return nil.
    #
    # Returns the duplicated String.
    def default_version
      1
    end

    # Public: Returns a versioned action name based on the requested action name
    # and an optional version specification on the request.  If no versioned
    # action matching what we think the request is trying to access is defined on
    # the containing class then this will behave in one of two ways:
    #   1. If #action_missing is defined, this method will return "_handle_aciton_missing"
    #      to stay in line with how the default Rails implementation works
    #   2. If #action_missiong is not defined, then this will return nil (preserves)
    #      default rails behavior)
    #
    # action - The name of the action to look up, a String
    #
    # Returns a versioned action name, "_handle_action_missing", or nil
    def method_for_action(action)
      version = (requested_version || self.default_version)

      unless version.nil?
        version = version.to_i
        method = nil
        version.downto(1) do |v|
          name = "#{action}_v#{v}"
          method ||= self.respond_to?(name) ? name : nil
        end
      end

      method ||= self.respond_to?("action_missing") ? "_handle_action_missing" : nil
    end


    # Public: Finds the API version requested in the request
    #
    # Returns the requested version, or nil if no version was specifically requested
    def requested_version
      accept_headers = request.headers["HTTP_ACCEPT"]
      return nil if accept_headers.nil?
      parts = accept_headers.split(",").map(&:strip)
      requested = parts.map{|part| part.match(/version=(\d+)/)[1] if part.match(/version=\d+/)}.detect{|i| !i.nil?}
      requested.to_i unless requested.nil?
    end

  end
end
