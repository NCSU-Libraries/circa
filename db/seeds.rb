# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Rename legacy values if they exist
enumeration = Enumeration.find_by(name: 'patron_type')
if enumeration
  enumeration.update_attributes(name: 'researcher_type')
end

user_role = UserRole.find_by(name: 'patron')
if user_role
  user_role.update_attributes(name: 'researcher')
end


# Order types

order_types = [
  { name: 'research', label: 'research' },
  { name: 'reproduction', label: 'reproduction' },
  { name: 'processing', label: 'processing/treatment' },
  { name: 'exhibition', label: 'exhibition/loan' }
]

order_types.each do |ot|
  if !OrderType.exists?(name: ot[:name])
    OrderType.create!(ot)
    puts "Created order_type #{ ot[:name] }"
  else
    puts "order_type #{ ot[:name] } already exists"
  end
end

research_order_type = OrderType.where(name: 'research').first
reproduction_order_type = OrderType.where(name: 'reproduction').first
processing_order_type = OrderType.where(name: 'processing').first
exhibition_order_type = OrderType.where(name: 'exhibition').first

order_sub_types = [
  { name: 'independent_research', label: 'independent research', order_type_id: research_order_type.id },
  { name: 'course_reserve', label: 'course reserve', order_type_id: research_order_type.id },
  { name: 'reproduction_no_fee', label: 'reproduction request, no fee', order_type_id: reproduction_order_type.id },
  { name: 'reproduction_fee', label: 'reproduction request, fee required', order_type_id: reproduction_order_type.id },
  { name: 'preservation', label: 'preservation treatment ', order_type_id: processing_order_type.id },
  { name: 'processing', label: 'processing', order_type_id: processing_order_type.id },
  { name: 'bulk_digitization', label: 'bulk digitization', order_type_id: processing_order_type.id },
  { name: 'staff_use', label: 'staff use', order_type_id: processing_order_type.id },
  { name: 'born_digital_processing', label: 'born-digital processing ', order_type_id: processing_order_type.id },
  { name: 'exhibition', label: 'exhibition', order_type_id: exhibition_order_type.id },
  { name: 'loan', label: 'special loan ', order_type_id: exhibition_order_type.id }
]

order_sub_types.each do |ost|
  if !OrderSubType.exists?(name: ost[:name])
    OrderSubType.create!(ost)
    puts "Created order_sub_type #{ ost[:name] }"
  else
    puts "order_sub_type #{ ost[:name] } already exists"
  end
end


# User roles

roles = [
  { name: 'superadmin', level: 0 },
  { name: 'admin', level: 1 },
  { name: 'staff', level: 10 },
  { name: 'researcher', level: 20 }
]

roles.each do |r|
  if !UserRole.exists?(name: r[:name])
    UserRole.create!(r)
     puts "UserRole #{ r[:name] } created"
  end
end


# Enumeration values

enumerations = {
  'researcher_type' => [
    ['faculty','faculty'],
    ['graduate student','graduate_student'],
    ['undergraduate','undergraduate'],
    ['staff','staff'],
    ['visiting researcher (undergraduate)','visiting_researcher_undergraduate'],
    ['visiting researcher (graduate student)','visiting_researcher_graduate_student'],
    ['visiting researcher (college/university faculty)','visiting_researcher_faculty'],
    ['visiting researcher (other/independent)','visiting_researcher']
  ],
  'location_source' => [
    ['ArchivesSpace','archivesspace'],
    ['Circa','circa'],
    ['Catalog','catalog'],
  ]
}

enumerations.each do |enumeration, values|
  e = Enumeration.find_by_name(enumeration)

  if !e
    e = Enumeration.create!(name: enumeration)
    puts "Enumeration '#{enumeration}' created"
  else
    puts "Enumeration '#{enumeration}' exists"
  end

  values.each do |v|
    if (v.kind_of?(Array))
      value_short = v[1]
      attributes = { value: v[0], value_short: value_short, enumeration_id: e.id }
    else
      value_short = v.downcase
      attributes = { value: v, value_short: v.downcase, enumeration_id: e.id }
    end
    value = EnumerationValue.find_by(value_short: value_short, enumeration_id: e.id)

    if !value
      value = EnumerationValue.create!(attributes)
      puts "EnumerationValue '#{v}' for Enumeration '#{enumeration}' created"
    else
      puts "EnumerationValue '#{v}' for Enumeration '#{enumeration}' exists - updating"
      value.update_attributes(attributes)
    end
  end
end


reproduction_formats = [
  {
    name: "photocopy/low-res scan (150 dpi)",
    default_unit_fee_internal: 0.25,
    default_unit_fee_external: 0.50,
    description: nil
  },
  {
    name: "digital scan",
    default_unit_fee_internal: 5.00,
    default_unit_fee_external: 15.00,
    description: nil
  },
  {
    name: "digital camera/cell phone image",
    default_unit_fee_internal: nil,
    default_unit_fee_external: nil,
    description: "No charge. In-person only."
  },
  {
    name: "oversize digital scan",
    default_unit_fee_internal: 10.00,
    default_unit_fee_external: 20.00,
    description: "A $35 set-up and processing fee may be added."
  },
  {
    name: "A/V digitization",
    default_unit_fee_internal: nil,
    default_unit_fee_external: nil,
    description: "Fees are determined on a case-by-case basis; an estimate will be given before the order is finalized. A $35 set-up and processing fee may be added."
  }
]

# Only run if the table is empty
if ReproductionFormat.count == 0
  reproduction_formats.each do |atts|
    ReproductionFormat.create!(atts)
  end
end
