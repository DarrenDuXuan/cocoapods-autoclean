
#!/bin/bash

gem uninstall cocoapods-autoclean
gem build cocoapods-autoclean.gemspec
gem install cocoapods-autoclean-0.0.1.gem
pod plugins installed
