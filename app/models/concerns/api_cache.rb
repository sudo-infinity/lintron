module ApiCache
  extend ActiveSupport::Concern

  def api_cache
    @_api_cache ||= {}
  end

  def cache_api_request(name, &block)
    api_cache[name] ||= yield block
  end

  def reset_api_cache!
    @_api_cache = {}
  end
end
