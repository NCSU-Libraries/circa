module ApplicationHelper

  def options(option)
    @options = YAML.load_file('config/options.yml')
    @options[option]
  end

end
