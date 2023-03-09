require 'cocoapods-autoclean/config/autoclean_config'
module Pod
    class Config
        include AutocleanConfig
    end
end