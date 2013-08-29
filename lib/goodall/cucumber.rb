require 'goodall'

Before do |scenario|
  if scenario.feature != $current_feature
    $current_feature = scenario.feature
    Goodall::Logger.write("#{'-'*80}\nFeature: #{$current_feature.name}")
    Goodall::Logger.write("\n")
  end
  Goodall::Logger.write("Scenario: #{scenario.name}")
  Goodall::Logger.write("\n")
end