require 'json'
require 'thread/pool'
require_relative 'result'
require_relative 'promise'
require 'oga'
require 'open-uri'
require 'net/http'

def fetch_url(url)
	Result.success(data: open(url).read)
rescue Net::OpenTimeout
	Result.error(url, code: :net_open_timeout)
end

def parse_json(data)
	Result.success(data: JSON.parse(data))
rescue JSON::ParserError
	Result.error(data, code: :json_parser_error)
end

def load_file(filename)
	File.read(filename)
end

def get_json(url)
	Promise.new(value: url).
		then {|url| fetch_url(url)}.
		then {|body| parse_json(body)}.
		resolve
end

def parse_xml(content)
	data = Oga.parse_xml(content)
	Result.success(data: {
		debug: data.to_xml,
	})

rescue LL::ParserError
	Result.error(data: content, code: :xml_parser_error)
end

def get_xml(url)
	Promise.new(value: url).
		then {|url| fetch_url(url)}.
		then {|body| parse_xml(body)}.
		resolve
end

def dump_result(result)
	{
		success: result.success?,
		code: result.code,
		data: result.data,
	}
end

def load_json(filename:)
	Promise.new(value: filename).
		then {|filename| load_file(filename)}.
		then {|content| parse_json(content)}.
		resolve
end

def fetch_list_page(url:, filename:)
	if File.exists?(filename)
	       =JSON.parse(File.read(filename))
	result = get_json(url)
	if result.error?
		puts "Error while fetching '#{url}'"
		exit 1
	end
	File.write(filename, JSON.pretty_generate(result.data))
	puts "List page saved to disk: #{filename}"
	result.data
end

fetch_list_page(url: 'http://dati.anticorruzione.it/data/l190-2017.json', filename: 'l190-2017.json')
return 0

POOL_SIZE = 100
puts "Fetching #{pa_list.size} URLs with a pool of #{POOL_SIZE} threads"

pool = Thread.pool(POOL_SIZE)
pa_list.each_with_index do |pa, index|
	if pa['esitoUltimoTentativoAccessoUrl'] === 'fallito'
		print 'f'
		next
	end
	pool.process do
		result = get_xml(pa['url'])
		if result.success?
			print '.'
		else
			print 'x'
		end
		queue << result
	end
end
pool.shutdown
puts "\nDone."
data = []
loop do
	break if queue.empty?
	result = queue.shift
	data << {
		success: result.success?,
		code: result.code,
		data: result.data,
	}
end

File.write('results.json', JSON.pretty_generate(data))
puts "Results persisted to 'results.json'."

