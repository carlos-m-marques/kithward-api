require 'awesome_print'
require 'json'

Hash.class_eval do

  def decent_fetch(*args, &block)
    fetch(*args, &block)
  rescue KeyError
    key = args.first
    raise KeyError, "Key #{key.inspect} not found in #{self.inspect}"
  end

end

class Processing
  attr_reader :dictionary, :sections, :data_types, :groups, :compiled_data, :compiled_data_from_db, :db_report, :report

  def initialize(dictionary)
    @dictionary = dictionary
    @sections = []
    @data_types = []
    @groups = []
    @db_report = nil
    @report = nil
    @compiled_data = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = [] } }
    @compiled_data_from_db = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = [] } }
  end

  def crunch
    dictionary.each do |section|
      begin
        next unless section[:groups]

        @compiled_data["#{section.decent_fetch(:label)} - #{section.decent_fetch(:section)}"]

        group_names = section[:groups].map(&:to_a).map(&:first).to_h

        section.decent_fetch(:attrs).each do |attr|
          attr_name = attr.keys[0]
          attr = attr.values[0]

          next unless attr[:group]

          group_name = if group_names[attr.decent_fetch(:group).to_sym][:label]
            "#{group_names[attr.decent_fetch(:group).to_sym][:label]} - #{attr.decent_fetch(:group)}"
          else
            attr.decent_fetch(:group)
          end

          attributes = { label: attr.decent_fetch(:label), data_type: attr.decent_fetch(:data), db_name: attr_name }
          attributes.merge!(values: attr.decent_fetch(:values)) if attr[:values]
          @compiled_data["#{section.decent_fetch(:label)} - #{section.decent_fetch(:section)}"]["#{group_name}"] << attributes
        end
      end
    end

    dictionary.each do |section|
      next unless section[:attrs]

      section[:attrs].each do |attr|
        attr_db_name = attr.keys[0]

        group_names = if section[:groups]
          section[:groups].map(&:to_a).map(&:first).to_h
        else
          {}
        end

        all_attributes = { section_label: section.decent_fetch(:label), section_name: section.decent_fetch(:section), data_type: attr[attr_db_name][:data] }

        gg = group_names[attr[attr_db_name][:group].to_sym][:label] || attr[attr_db_name][:group] if attr[attr_db_name][:group]

        all_attributes.merge!(group_name: gg) if gg
        all_attributes.merge!(values: attr[attr_db_name][:values]) if attr[attr_db_name][:values]

       @compiled_data_from_db[attr_db_name] = all_attributes
      end
    end

    @report = ''
    @compiled_data.each do |key, value|
      @report << key.to_s.purple
      @report << "\n\n"
      @report << "\tGroups:\n\n".blue
      value.each do |group_name, attributes|
        @report << "\t\t#{group_name}:\n".green
        attributes.each do |attribute|
          @report << "\t\t\t#{attribute[:label]}".red
          @report << "\n\t\t\t  Data Type: ".cyanish
          @report << "#{attribute[:data_type]}\n".greenish
          @report << "\t\t\t  DB Name: ".cyanish
          @report << "#{attribute[:db_name]}\n".greenish
          if attribute[:values]
            @report << "\t\t\t  Values:\n".cyanish
            attribute[:values].map do |hash|
              @report << "\t\t\t\t  #{hash.values[0]} - #{hash.keys[0]}\n".purpleish
            end
          end
        end
      end
    end
    @db_report = ''
    @compiled_data_from_db.each do |key, value|
      @db_report << key.to_s.purple
      @db_report << "\n"
      value.each do |key, value|
        unless key == :values
          @db_report << "\t#{key}: ".blue
          @db_report << " #{value}\n".red
        else
          @db_report << "\t#{key}: \n".blue
          value.each do |key_value|
            @db_report << "\t\t#{key_value.keys[0]}: ".blue
            @db_report << " #{key_value.values[0]}\n".red
          end
        end
      end
    end
  end



  def db_report
    puts @db_report
  end

  def report
    puts @report
  end
end
