def values(values)

  case values.first[0]
  when "{"
    return to_h(values)
  when "["
    return to_a(values)
  else
    puts "value is string: '#{values}'"
    return values.join(" ")
  end

end

def to_h(values)

  vals = values.inject({}) do |memo, val|
    if val.include?(":")
      bits = val.split(":")
      raise "expected key:value" unless bits.size == 2
      memo[bits.first.gsub(/^\{/,"")] = bits.last.gsub(/\}$/,"")
    end
    memo
  end

  puts "value is hash: #{vals}"

end

def to_a(values)

  values[0] = values.first.gsub(/^\[/,"")
  values[values.size - 1] = values.last.gsub(/\]$/,"") 
  values.delete_if{|val| val.nil? || val.empty? }

  puts "value is array: #{values}"

  values  

end

def hostname_ok?(name)
  name =~ /^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$/
end
