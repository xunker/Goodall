require 'goodall'
require 'goodall/command_line_enable'

Before do |scenario|

  # skip scenarios that have the '@dont-document' tag
  if scenario.source_tags.map(&:name).include?('@dont-document')
    Goodall.skipping_on!
  end

  next if Goodall.skipping?

  if scenario.feature != $current_feature
    $current_feature = scenario.feature
    Goodall.write("\n")
    Goodall.write("#{'-'*80}\nFeature: #{$current_feature.name}")
  end
  Goodall.write("\n")
  Goodall.write("Scenario: #{scenario.name}")
  Goodall.write("\n")
end

After do |scenario|
  Goodall.skipping_off! if Goodall.skipping?
end