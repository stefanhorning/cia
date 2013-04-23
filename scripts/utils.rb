def values(values)
  val = eval(values.join(" "))
  puts "value is a #{val.class}: #{val}"
  val 
end

def hostname_ok?(name)
  name =~ /^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$/
end
