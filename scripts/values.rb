def split(values)

  values.inject({}) do |memo, val|
    bits = val.split(":")
    raise "expected key:value" unless bits.size == 2
    memo[bits.first] = bits.last
    memo
  end

end
