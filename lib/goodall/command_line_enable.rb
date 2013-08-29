if (ENV["ENABLE_GOODALL"].to_s.size > 0) && (ENV["ENABLE_GOODALL"].to_s.upcase != 'FALSE')
  Goodall::Logger.enable
end 
