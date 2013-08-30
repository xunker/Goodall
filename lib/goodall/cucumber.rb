require 'goodall'
require 'goodall/command_line_enable'

Before do |scenario|
  if scenario.feature != $current_feature
    $current_feature = scenario.feature
    Goodall.write("#{'-'*80}\nFeature: #{$current_feature.name}")
    Goodall.write("\n")
  end
  Goodall.write("Scenario: #{scenario.name}")
  Goodall.write("\n")
end