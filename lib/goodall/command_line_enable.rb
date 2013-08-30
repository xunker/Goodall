if (ENV["ENABLE_GOODALL"].to_s.size > 0) && (ENV["ENABLE_GOODALL"].to_s.upcase != 'FALSE')
  Goodall::Logger.enable
end 

if (ENV["GOODALL_OUTPUT_PATH"].to_s.size > 0)
  Goodall::Logger.output_path = ENV["GOODALL_OUTPUT_PATH"]
end 

