module Cloudchart
  module RFC1751
    
    extend self
    
    class ParityError < ArgumentError
    end

    def encode(uuid)
      parts = uuid.gsub('-', '').scan(/.{16}/).map { |n| n.to_i(16) }
      parts.map { |part| words(part) }.join(' ')
    end
    
    def decode(string)
      words = string.upcase.split(' ')
      raise ParityError unless words.length == 12
      "%s%s-%s-%s-%s-%s%s%s" % words.each_slice(6).map { |part| '%016x' % numbers(part) }.join('').scan(/.{4}/)
    end
  
  private
  
  
    def bits(number)
      63.downto(0).map { |i| number[i] }
    end
  

    def words(number)
      data = bits(number).each_slice(11).inject([]) { |memo, i| memo << i.join('').to_i(2) ; memo }
      data[data.size - 1] = (data[data.size - 1] << 2) + parity(number)
      data.map { |i| WORDS[i] }
    end
    
    def numbers(words)
      result = words.inject(0) { |memo, number| (memo << 11) + WORDS.index(number) } >> 2
      raise ParityError unless (WORDS.index(words.last) & 3) == parity(result)
      result
    end
    
    def parity(number)
      bits(number).each_slice(2).inject(0) { |memo, i| memo + i.join('').to_i(2) } & 3
    end
    
  end
end
