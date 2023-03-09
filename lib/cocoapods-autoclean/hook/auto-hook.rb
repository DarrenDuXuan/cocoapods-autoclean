require 'cocoapods-autoclean/config'
require 'cocoapods-autoclean/autocleaner'

module CocoapodsAutocleanHooks
    Pod::HooksManager.register('cocoapods-autoclean', :post_install) do |context|
        AutocleanModule::Autocleaner.new(context).autoclean
    end
end