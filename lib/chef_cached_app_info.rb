require 'json'

class AppCache
  def self.at(cookbook_path)
    AppCache.new(cookbook_path)
  end

  def initialize(cookbook_path)
    @cookbook_path = cookbook_path
  end

  def cache_versions(origin_file)
    cached_app_info('app_version', origin_file)
    cached_app_info('cookbook_version', origin_file, lambda { |x| x.gsub(/[^0-9.]/i, '') })
  end

  def cached_app_info(key, origin_file = nil, content_lambda = lambda { |x| x })
    # Cache the original piece of info generated when building the app, so we have it when the app & infra are separated.
    write_info(key, content_lambda.call(IO.read(origin_file).strip)) if origin_file != nil && File.exist?(origin_file)
    # Cached version must always exist
    value = cached_app_info_object[key]
    raise "The cached app information stored by #{key} could not be found." if value.nil?
    value
  end

  def cached_app_info_file
    info_file = File.join(@cookbook_path, 'cached_app_info.json')
    IO.write(info_file, '{}') unless File.exist?(info_file)
    info_file
  end

  def cached_app_info_object
    JSON.parse(File.read(cached_app_info_file))
  end

  def write_info(key, value)
    info = cached_app_info_object
    info[key] = value
    IO.write(cached_app_info_file, info.to_json)
  end
end
