require 'json'
require 'erb'

def candidates_data
    JSON.parse(File.read('data/candidates.json'))
end
def measures_data
    JSON.parse(File.read('data/measures.json'))
end
def get_ordinal n
    n = n.to_i
    s = ["th","st","nd","rd"]
    v = n % 100
    "#{n}#{(s[(v-20)%10]||s[v]||s[0])}"
end
def make_uri(string)
    string.downcase.gsub(' ','-').gsub(/[^a-zA-Z0-9\-]/,'')
end

class Controller

    def initialize
        self.load_config
    end

    def set_meta meta_data=nil
        base_hash = Hash[ @base.to_h.map{ |k,v| [k.to_s, v] } ]
        @meta = base_hash.update(meta_data || {})
        unless @meta['image'].index(@base.url)
            @meta['image'] = URI.join(@base.url, @meta['image'])
        end
        render('_meta.erb')
    end

    def filename
        @filename
    end

    def party_name(party)
        { DEM: 'Democratic', REP: 'Republican' }[party.to_sym]
    end

    def load_config
        @base = OpenStruct.new JSON::parse(File.read('data/config.json'))
    end

    def index
        @meta_partial = set_meta
        @candidates = candidates_data
        @contests = @candidates.map{ |cand| cand['office'] }.uniq
    end

    def candidates candidate
        name = candidate['name']
        office = candidate['office']
        @anchor =  "@#{candidate['office']}-#{candidate['party']}"
        @filename = "candidates/#{make_uri candidate['office']}-"\
                    "#{make_uri candidate['name']}"
        @meta_partial = set_meta({
            'url' => "#{@base.url}/sharing/#{@filename}",
            'image' => "#{@base.url}/#{candidate['photo']}",
            'title' => "Vote #{name} for #{office}",
            'description' => "Vote #{name} for #{office} - and you should too",
        })
    end

    def render path
        ERB.new(File.read(path)).result(binding)
    end
end
