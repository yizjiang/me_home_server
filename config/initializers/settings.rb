variable_config = YAML.load(ERB.new(File.read('./config/settings.yml')).result)
