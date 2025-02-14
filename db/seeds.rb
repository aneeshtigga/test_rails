# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# helper = PeopleHelper
# age = 42
# barney = Person.where(
#         {first_name: 'Bernard', preferred_name: 'Barney', middle_name: 'Matthew',
#         last_name: 'Rubble', date_of_birth: helper.calc_dob(age),
#         gender_assigned_at_birth: 'male', gender_identification: 'male',
#         uuid: '', amd_id: ''}).first_or_create

# age = 38
# betty = Person.where(
#         {first_name: 'Elizabeth', preferred_name: 'Betty', middle_name: 'Jean',
#         last_name: 'Rubble', date_of_birth: helper.calc_dob(age),
#         gender_assigned_at_birth: 'female', gender_identification: 'female',
#         uuid: '', amd_id: ''}).first_or_create

# age = 10
# bamm_bamm = Person.where(
#         {first_name: 'Bamm-Bamm', preferred_name: '', middle_name: '',
#         last_name: 'Rubble', date_of_birth: helper.calc_dob(age),
#         gender_assigned_at_birth: 'male', gender_identification: 'male',
#         uuid: '', amd_id: ''}).first_or_create

# desc = 'Child'
# code = HippaRelationshipCode.where(description: desc).first.code
# Relation.create [
#   { party1_id: barney.id, party2_id: bamm_bamm.id, relationship_code: code },
#   { party1_id: betty.id,  party2_id: bamm_bamm.id, relationship_code: code }
# ]

# age = 71
# jean = Person.where(
#         {first_name: 'Jean', preferred_name: '', middle_name: '',
#         last_name: 'McBricker', date_of_birth: helper.calc_dob(age),
#         gender_assigned_at_birth: 'female', gender_identification: 'female',
#         uuid: '', amd_id: ''}).first_or_create

# desc = 'Mother'
# code = HippaRelationshipCode.where(description: desc).first.code
# Relation.create [
#   { party1_id: betty.id,  party2_id: jean.id, relationship_code: code }
# ]

# seeds for Address Type model

# %w[Landline Cell TextEnabled].each_with_index do |value, index|
#   PhoneType.where(code: (index + 10).to_s, description: value, active: true).first_or_create
# end

# seeds for person,address and insuranceCoverage collection
# 1
# person = Person.create(first_name:'Yeshvi',last_name:'Nani',date_of_birth:'04/01/1993',gender_assigned_at_birth: 'male')

# type = 'Home'
# address_type = AddressType.find_by(description: type)

# person.addresses.create(address_line1:'3rd avenue',city:'Atlanta',state:'Florida',postal_code:'30301', address_code: address_type.code )

# type = 'Landline'
# phone_type = PhoneType.find_by(description: type)

# person.phones.create(phone_number: '9876543210', phone_type_code: phone_type.code)

# InsuranceCoverage.create(company_name: 'Florida Blues',member_id: 'm125',group_id: 'g123',policy_holder: person)
# 2
# person = Person.create(first_name:'Subash',last_name:'Nivas',date_of_birth:'04/01/1992',gender_assigned_at_birth: 'male')

# type = 'Office'
# address_type = AddressType.find_by(description: type)

# person.addresses.create(address_line1:'Swan Square residence',city:'Tampa',state:'Florida',postal_code:'33602',address_code: address_type.code)

# type = 'Cell'
# phone_type = PhoneType.find_by(description: type)

# person.phones.create(phone_number: '9876533210', phone_type_code: phone_type.code)

# InsuranceCoverage.create(company_name: 'Aetna',member_id: 'm126',group_id: 'g121',policy_holder: person)

# 3

# person = Person.create(first_name:'Sree',last_name:'Nivas',date_of_birth:'04/07/1992',gender_assigned_at_birth: 'male')

# type = 'Mailing'
# address_type = AddressType.find_by(description: type)

# person.addresses.create(address_line1:'4th back street',city:'Atlanta',state:'Florida',postal_code:'30301',address_code: address_type.code)

# type = 'TextEnabled'
# phone_type = PhoneType.find_by(description: type)

# person.phones.create(phone_number: '9876513210', phone_type_code: phone_type.code)

# InsuranceCoverage.create(company_name: 'Blues care',member_id: 'm225',group_id: 'g113',policy_holder: person)

# #4
# person = Person.create(first_name:'Havel',last_name:'Tods',date_of_birth:'04/01/1993',gender_assigned_at_birth: 'male')

# type = 'Billing'
# address_type = AddressType.find_by(description: type)

# person.addresses.create(address_line1:'3rd avenue',city:'Atlanta',state:'Florida',postal_code:'30301',address_code: address_type.code)

# type = 'Landline'
# phone_type = PhoneType.find_by(description: type)

# person.phones.create(phone_number: '9876543110', phone_type_code: phone_type.code)

# InsuranceCoverage.create(company_name: 'qwent',member_id: 'm236',group_id: 'g221',policy_holder: person)

# #5
# person = Person.create(first_name:'randy',preferred_name: 'RKO',last_name:'ortan',date_of_birth:'04/01/1987',gender_assigned_at_birth:'male')

# type = 'Office'
# address_type = AddressType.find_by(description: type)

# person.addresses.create(address_line1:'west vicinity',city:'Atlanta',state:'Florida',postal_code:'30301',address_code: address_type.code)

# type = 'Landline'
# phone_type = PhoneType.find_by(description: type)

# person.phones.create(phone_number: '9876543220', phone_type_code: phone_type.code)

# InsuranceCoverage.create(company_name: 'west city covers',member_id: 'm536',group_id: 'g291',policy_holder: person)

# 5.times do |i|
#   BirdeyeAppointment.create({
#     first_name: "Jim #{i}",
#     last_name: 'Doe',
#     email: "jim#{i}@example.com",
#     phone: "415-797-998#{i}",
#   })
# end