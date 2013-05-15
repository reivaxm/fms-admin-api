require 'net/http'
require 'active_support'
require 'nokogiri'
require 'time'

module FMS
  class ConnectionError < Exception;end
  class Client

    attr_reader :base_params

    def initialize(options = {})
      raise ArgumentError, ":host option is required" unless options.include? :host

      defaults = {:auser => 'fms', :apswd => 'fms', :port => 1111}
      defaults.update(options)

      @http = Net::HTTP.new(defaults[:host],defaults[:port])
      @http.open_timeout = options[:timeout] unless options[:timeout].nil?
      @http.read_timeout = options[:timeout] unless options[:timeout].nil?
      @base_params = {:auser => defaults[:auser], :apswd => defaults[:apswd]}
      raise ConnectionError, 'Unable to ping server connection' unless resp_parsor(request(:ping))[:level] == :status
    end

    def method_missing(meth, *args)
      meth = ActiveSupport::Inflector.camelize(meth.to_s, false)
      if args.length == 1
        params = args[0]
      else
        params = {}
      end
      resp_parsor(request(meth, camelize_params(params)))
    end
    def self.id2FMSid(data)
      [data.to_i].pack('q*')
    end
    def self.FMSid2id(data)
      data.to_s.unpack('q*')[0]
    end

    private

    def resp_parsor(data)
      Rails.logger.debug(data)
      xml = Nokogiri::XML(data)
      fms_response = {}
      fms_response[:level] = xml.xpath('/result/level').text.to_sym
      fms_response[:code] = xml.xpath('/result/code').text
      fms_response[:time] = Time.httpdate(xml.xpath('/result/timestamp').text)
      fms_response[:error] = xml.xpath('/result/description').text if fms_response[:level] == :error
      fms_response.merge!(data_parsor(xml.xpath('/result/data'))) if fms_response[:level] == :status
      return fms_response
    end

    def request(action, params = {})
      get = build_url action, params
      resp = @http.request(get)
      raise NoMethodError, "#{action.inspect} is not a valid API method" unless resp.code == "200"
      resp.body
    end

    def build_url(method, extra_params = {})
      params = @base_params.merge(extra_params).map{|k,v| "#{k}=#{v}"}.join('&')
      get = Net::HTTP::Get.new("/admin/#{method}?#{params}")
      Rails.logger.debug(get.path)
      get
    end

    def camelize_params(params)
      cam_params = {}
      params.each_pair do |key, value|
        cam_params[ActiveSupport::Inflector.camelize(key.to_s, false)] = value
      end
      cam_params
    end
    def time_parse(time)
      begin
        return Time.parse(time)
      rescue ArgumentError
        t = time.match(/(\d{2})\/(\d{2})\/(\d{4})\s(\d{2}):(\d{2}):(\d{2})/)
        return Time.mktime(t[3],t[2],t[1],t[4],t[5],t[6])
      end
    end
    def data_parsor(data)
      out_hash={}
      data.each do |node|
        next unless node.is_a? Nokogiri::XML::Element
        if node.children.count != 1
          out_hash[node.name.to_sym] = data_parsor(node.children)
        else
          value = node.children.text
          value = time_parse(value) if node.name.match(/^(up_)time/)
          out_hash[node.name.to_sym] = value
        end
      end
      out_hash
    end
  end
end
