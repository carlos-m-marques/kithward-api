require 'awesome_print'
require 'json'
require 'processing'
require 'scriptster'
require 'ruby-progressbar'

Scriptster::configure do |conf|
  conf.name = "Community"
  conf.verbosity = :verbose
  conf.file = 'log/import.log'
  conf.colours = :light
  conf.log_format = "%{timestamp} %{name} %{message}"
end

class Oops < StandardError;end

class Converter
  attr_reader :db_report

  def initialize
    processing = Processing.new(COMMUNITY)
    processing.crunch

    @db_report = processing.compiled_data_from_db
  end

  def ui_type_by_data_type
    types = Hash.new('text')
    types.merge({
      'flag' => 'boolean',
      'amenity' => 'boolean',
      'rating' => 'range',
      'select' => 'select',
      'number' => 'number',
      'list_of_ids' => 'multiple-select',
      'currency' => 'text',
      'ratio' =>  'text',
      'pricerange' => 'range',
      'numberrange' => 'range'
    })
  end

  def independent_living_super_classes
    CommunitySuperClass.independent_living
  end

  def assisted_living_super_classes
    CommunitySuperClass.assisted_living
  end

  def skilled_nursing_super_classes
    CommunitySuperClass.skilled_nursing
  end

  def memory_care_super_classes
    CommunitySuperClass.memory_care
  end

  def il_communities
    Community.care_type_il
  end

  def al_communities
    Community.care_type_al
  end

  def sn_communities
    Community.care_type_sn
  end

  def mc_communities
    Community.care_type_mc
  end

  def log(message, level = :info)
    Scriptster.log level, message
  end

  def create_super_classes(attribute, data)
    if CommunitySuperClass.where(name: data[:section_label]).count == 0
      CommunitySuperClass.create([{ independent_living: true, name: data[:section_label] }, { assisted_living: true, name: data[:section_label] }, { skilled_nursing: true, name: data[:section_label] }, { memory_care: true, name: data[:section_label] }])
    end
  end

  def create_classes(attribute, data)
    if KwClass.where(name: data[:group_name].capitalize).count == 0
      CommunitySuperClass.where(name: data[:section_label]).each do |super_class|
        KwClass.create({ name: data[:group_name].capitalize, kw_super_class_id: super_class.id })
      end
    end
  end

  def create_attributes(attribute, data)
    if KwAttribute.where(name: data[:label]).count == 0
      KwClass.where(name: data[:group_name].capitalize).each do |klass|
        attributes = { name: data[:label], hidden: data[:hidden], ui_type: ui_type_by_data_type[data[:data_type]], kw_class_id: klass.id }
        attributes.merge!(values: data[:values].map(&:values).map(&:last)) if data[:values]

        kw_attribute = KwAttribute.create(attributes)
      end
    end
  end

  def create_all(attribute, data)
    create_super_classes(attribute, data)
    create_classes(attribute, data)
    create_attributes(attribute, data)
  end

  def convert
    logger = Rails.logger
    base_logger = ActiveRecord::Base.logger
    dev_null = Logger.new("/dev/null")

    Rails.logger = dev_null
    ActiveRecord::Base.logger = dev_null

    KwValue.delete_all
    KwAttribute.delete_all
    KwClass.delete_all
    KwSuperClass.delete_all
    RelatedCommunity.delete_all

    log "Creating super classes..."
    log "Creating classes..."
    log "Creating the attributes..."
    log "Setting KwAttributes to values..."

    db_report.each do |attribute, data|
      next if data.keys.count < 6
      create_all(attribute.to_s, data)
    end

    log "Done with that!"

    set_attributes_on_db_report

    do_it!

    Rails.logger = logger
    ActiveRecord::Base.logger = base_logger

  end

  def set_attributes_on_db_report6
    @db_report.each do |attribute, data|
      next if data.keys.count < 6
      data.merge!(attributes: KwAttribute.where(name: data[:label]).map{ |attr| [Community::TYPE_FOR_LABEL[attr.care_type], attr] }.to_h)
    end
  end

  def do_it!
    progressbar = ProgressBar.create(title: "Community", starting_at: 0, length: 150, format: "%B [%%%P] %e | %c processed", total: Community.count)

    Community.in_batches(of: 100) do |batch|
      batch.each do |community|
        progressbar.increment

        community.data.each do |k, v|
          data = @db_report[k.to_sym]

          next if data.keys.count < 6
          next unless Community::CARE_TYPES.include?(community.care_type)

          case ui_type_by_data_type[data[:data_type]]
          when 'select'
            values = data[:values].map{ |v| [v.keys[0], v.values[0]] }.to_h
            if values[v]
              community.kw_values.create(kw_attribute_id: data[:attributes][community.care_type].id, name: values[v])
            else
              v.split(',').each do |vv|
                if values[vv]
                  community.kw_values.create(kw_attribute_id: data[:attributes][community.care_type].id, name: values[vv])
                end
              end
            end
          when 'multiple-select'
            if v.split(',').count > 1
              v.split(',').each do |community_id|
                rc = Community.where(id: community_id).last
                community.related_communities << rc if rc
              end
            else
              rc = Community.where(id: v).last
              community.related_communities << rc if rc
            end
          when 'boolean'
            community.kw_values.create(kw_attribute_id: data[:attributes][community.care_type].id, name: data[:label]) if v
          else
            community.kw_values.create(kw_attribute_id: data[:attributes][community.care_type].id, name: v)
          end
        end
      end
    end
  end
end
