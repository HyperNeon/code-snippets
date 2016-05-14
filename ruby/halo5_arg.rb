#URL Brute Force
response = ''
url = "http://1drv.ms/1Z16e%s%s"
# url = "http://1drv.ms/1R2xJ%s%s"
url = "http://1drv.ms/1%s%s4QpS"
alpha = [*('A'..'Z'), *(0..9), *('a'..'z')]
alpha = [*('A'..'Z'), *(0..9)]
alpha.each do |a|
  alpha.each do |b|
    new_url = url % [a, b]
    puts new_url
    begin
      response = HTTParty.get(new_url)
      if response.code == 200
        puts "THIS URL WORKS!: #{new_url}" unless response.parsed_response.include?('http://searchassist.verizon.com')
      elsif response.parsed_response.include?('<title>Bitly | Forbidden | 403</title>')
        puts 'WERE BLOCKED'
        break
      end
    rescue
    end
  end
end


#Random Byte and Base Transformations

string = "QW\3^XVoOoh7RoZ<WPN;csZ7PJm6Spi6SYp6P}T~SrR7U‚bsU‚];XMZ>WMl;WKTUqX9cM^>WƒV9XWT6PlT}P\a‚VuY8VX]7RpO6T€XjPs_6UZW8RX]6QW\{Q\o8W\a;VmP3P|YoT`8V]VƒWvV<X][mRR2[\k<VLs8V‚a8U‚M:U~]9RER9WsbƒWv^7TqT€U[l€S€W;Tsl:WMcuWML5\sbWMp:b]ctWsZ;cMb3P}P8V[arUIZ7SV:RR6Vrk9V_M:\VZ>Wƒ^9X]Z8UH:V[]5RXp;bsb<WsV5R~VlRnk7R^:Wƒl;Wƒ^WoK3]WarUNT9U‚VsU:YE"
string.unpack('H*').first.scan(/../)

pi = '3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593344612847564823378678316527120190914564856692346034861045432664821339360726024914127372458700660631558817488152092096282925409171536436789259036001133053054882046652138414695194151160943305727036575959195309218611738193261179310511854807446237996274956735188575272489122793818301194912983367336244065664308602139494639522473719070217986094370277053921717629317675238467481846766940513200056812714526356082778577134275778960917'
pi_byte_array = pi.unpack('H*').first.scan(/../)


byte_transform = []
string.unpack('H*').first.scan(/../).each_with_index do |s, i|
  byte_transform << s.hex + pi_byte_array[i].hex
end

string2 = "%sd%s%sE%sGdE%s$$"
string2 = "%sd%s%sE%sGdE%s%s%s"
string1 = "%sd%s&E&GdE%s$$"
string3 = "%sd%s8386d3%s55"
new_string = ''
# (48..57).each do |a|
#   (48..57).each do |b|
#     (48..57).each do |c|
(33..126).each do |a|
   (33..126).each do |b|
     (33..126).each do |c|
      new_string = string3 % [a.chr, b.chr, c.chr]
      new_string = new_string.unpack('H*').first.reverse.to_bin.decode64
      puts new_string if new_string.ascii_only? && new_string != "\x15;E"
    end
  end
end
