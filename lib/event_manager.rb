require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  #Enjoy this next line... I made it nice and convoluted b/c Ruby ;)
  if !zipcode.nil? && zipcode.length < 5 then zipcode.insert(0, "0") while (zipcode.length < 5) elsif !zipcode.nil? && zipcode.length > 5 then zipcode = zipcode[0..4] elsif zipcode.nil? then zipcode = "00000" end
  return zipcode
end

def clean_phone_number(messy_number)
  number = ""
  iCount = 0
  messy_number.split("").each do |char|
    if char.ord >= "0".ord and char.ord <= "9".ord
      number << char
    end
  end

  if number.length == 11 and number[0] == "1"
    number = number[1..10]
  elsif number.length != 10
    return "bad"
  end
  number.insert(0, "(")
  number.insert(4, ")")
  number.insert(5, "-")
  number.insert(9, "-")
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
=begin Use this to return a string
    legislator_names = legislators.collect do |legislator|
    "#{legislator.first_name} #{legislator.last_name}"
  end
  legislator_names.join(", ")
=end
end


def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end


puts "EventManager Initialized!"

if !File.exist? '../event_attendees.csv' then abort("Attendees file not found.") end

=begin
Here is code for simply reading in the entire file:

contents = File.read '../event_attendees.csv'
puts contents
=end

=begin
Here we started building our own parser. That is not the goal

lines = File.readlines '../event_attendees.csv'

lines.each_with_index do |line, index| #Each
  row_index = row_index + 1
  next if row_index == 1
  columns = line.split(",")
  name = columns[2]
  puts name
end
=end

contents = CSV.open "../event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "../form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  phone_number = clean_phone_number(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)
end



