require 'json'
require 'erb'

def candidates_data
    JSON.parse(File.read('data/candidates.json'))
end

def measures_data
    JSON.parse(File.read('data/measures.json'))
end
def _get_ordinal n
    n = n.to_i
    s = ["th","st","nd","rd"]
    v = n % 100
    "#{n}#{(s[(v-20)%10]||s[v]||s[0])}"
end

class Controller

    def set_meta meta_data=nil
        meta_data ||= {}

        default_description = ("Vote by Tuesday, May 9th in the San "+
                               "Antonio City Election. Check out our voter "+
                               "guide to see who and what will be on your "+
                               "ballot.")

        default_title = '2015 San Antonio Voter Guide'

        default_image = ('http://www.sanantoniovoterguide.org/images'
                         '/shareable.png')

        @meta = {
            "title" => meta_data['title'] || default_title,
            "description" => meta_data['description'] || default_description,
            "image" => ("#{meta_data['image'] || default_image}"),
            "url" => (meta_data['url'] || 'http://www.sanantoniovoterguide.org'),
            "twitter_name" => 'movesanantonio',
            "twitter_hashtag" => 'sanantoniovotes',
        }
        render('_meta.erb')
    end

    def filename
        @filename
    end

    def index
        @meta_partial = set_meta
        candidates = candidates_data
        @mayors = candidates.select{ |can| can['office'] == 'mayor' }
        @counselors = candidates.reject{ |can| can['office'] == 'mayor' }
        @counselors =  @counselors.group_by{ |can| can['office'] }
        @measures = measures_data
    end

    def measure measure
        base = "http://www.sanantoniovoterguide.org"

        @anchor =  (measure['title'].downcase.gsub(' ','-')
                    .gsub(/[^a-zA-Z0-9\-]/,''))
        @filename = "measure/#{measure['choice']}-#{@anchor}"
        @meta_partial = set_meta({
            'url' => "#{base}/sharing/#{@filename}",
            'image' => "#{base}/images/#{measure['choice']}.png",
            'title' => "Vote #{measure['choice']} for #{measure['title']}",
            'description' => ("I'm supporting #{measure['choice']} on "
                              "#{measure['title']}. A "+
                              "#{measure['choice']} Vote means: "+
                              "#{measure['explanation']}"),
        })
    end

    def candidate candidate
        base = "http://www.sanantoniovoterguide.org"

        name = candidate['name']
        link = name.downcase.gsub(' ','-').gsub(/[^a-zA-Z0-9\-]/,'')
        @anchor =  "@!#{candidate['name']}"
        @filename = "candidate/#{candidate['office']}-#{link}"

        @meta_partial = set_meta({
            'url' => "#{base}/sharing/#{@filename}",
            'image' => "#{base}/#{candidate['photo']}",
            'title' => "Vote #{name} for #{candidate['office display name']}",
            'description' => ("I'm supporting #{name} for "+
                              "#{candidate['office display name']} - and "+
                              "you should too"),
        })
    end

    def render path
        ERB.new(File.read(path)).result(binding)
    end
end
