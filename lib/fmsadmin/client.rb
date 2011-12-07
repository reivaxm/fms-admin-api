require 'net/http'

module FMSAdmin

  class Client
    
    def initialize(host, user, password)
      @host = host
      @params = {
        :auser => user,
        :apswd => password
      }
    end

    def get_apps(force = false, verbose = true)
      extra_params = {
        :force => "false",
        :verbose => "false",
      }
      if force
        extra_params[:verbose] = "true"
        extra_params[:force] = "true"
      end
      if verbose
        extra_params[:verbose] = "true"
      end
      Net::HTTP.get(build_url(extra_params))
    end

    private

    def build_url(extra_params = {})
      url = URI("http://#{@host}/admin/getApps")
      url.query = URI.encode_www_form(@params.merge(extra_params))
      url
    end

  end

end