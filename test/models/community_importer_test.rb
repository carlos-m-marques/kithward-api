require 'test_helper'

class CommunityImporterTest < ActiveSupport::TestCase
  setup do
    DataDictionary::Community.stubs(:attributes).returns({
      care_type: {data: 'select', values: [{"A"=>"Assisted Living"}, {"I"=>"Independent Living"}], direct_model_attribute: true},
      name: {data: 'string', direct_model_attribute: true},
      street: {data: 'string', direct_model_attribute: true},
      city: {data: 'string', direct_model_attribute: true},
      state: {data: 'string', direct_model_attribute: true},
      postal: {data: 'string', direct_model_attribute: true},
      phone: {data: 'string'},
      notes: {data: 'text'},
      description: {data: 'text', direct_model_attribute: true},
      star_rating: {data: 'rating'},
      pool: {data: 'amenity'},
    }.with_indifferent_access)

    Geocoder::Lookup::Test.reset
    Geocoder::Lookup::Test.add_stub("101 Theall Road, Rye, NY, 10580, USA", [{'latitude' => 40.90, 'longitude' => -74.20}])
    Geocoder::Lookup::Test.add_stub("459 East Oak Orchard Street, Medina, NY, 14103, USA", [{'latitude' => 40.95, 'longitude' => -74.30}])
    Geocoder::Lookup::Test.add_stub("123 Broadway, New York, NY, 10001, USA", [{'latitude' => 40.75, 'longitude' => -74.00}])
    Geocoder::Lookup::Test.add_stub("125 Broadway, New York, NY, 10001, USA", [{'latitude' => 40.7501, 'longitude' => -74.00}])
    Geocoder::Lookup::Test.add_stub("200 Broadway, New York, NY, 10001, USA", [{'latitude' => 40.85, 'longitude' => -74.00}])
    Geocoder::Lookup::Test.add_stub("456 Broadway, New York, NY, 10002, USA", [{'latitude' => 40.80, 'longitude' => -74.10}])
    Geocoder::Lookup::Test.add_stub("789 Broadway, New York, NY, 10003, USA", [{'latitude' => 40.90, 'longitude' => -74.10}])
    Geocoder::Lookup::Test.add_stub("123 Broadway, Washington, DC, 20001, USA", [{'latitude' => 38.90, 'longitude' => -77.00}])

    @c1 = create(:community, name: 'Silver Lining', description: 'Incredible Care', care_type: 'I', street: '123 Broadway', city: 'New York', state: 'NY', postal: '10001', country: 'USA')
    @c1.geocode; @c1.save
    @c2 = create(:community, name: 'Golden Pond', description: 'Excelent Care', care_type: 'A', postal: '10001')
    @c3 = create(:community, name: 'Gray Peaks', description: 'Incredible Service', care_type: 'A', postal: '10001')
    @c4 = create(:community, name: 'Deleted Community', description: 'Useless Service', status: Community::STATUS_DELETED, postal: '10001')
    @c5 = create(:community, name: 'Gray Peaks', description: 'Incredible Service', care_type: 'I', postal: '20001')

    Community.reindex
  end

  test "It recognizes when there is no data" do
    importer = CommunityImporter.new data: ""

    results = importer.to_h

    assert_equal [], results[:entries]
    assert_equal [{error: "No data!"}], results[:messages]
  end

  test "It recognizes when there is malformed data" do
    importer = CommunityImporter.new data: <<-END
name,street\tcity
1,\"23\"4\"5\", 6
END

    results = importer.to_h

    assert_equal [], results[:entries]
    assert_equal [{error: "Malformed CSV: Illegal quoting in line 2."}], results[:messages]
  end

  test "It processes the headers" do
    importer = CommunityImporter.new data: <<-EOF
Care Type,Name,Street,City,State,Postal,Phone
AL,The Osborn,101 Theall Road,Rye,NY,10580,(914) 925-8200
AL,The Willows,459 East Oak Orchard Street,Medina,NY,14103,(585) 798-5233
EOF

    results = importer.to_h

    assert_equal 2, results[:entries].length
    assert_equal [
      {'attr' => "care_type", 'header' => "Care Type", 'pos' => 0, 'definition' => {'data' => 'select',  'values'=>[{"A"=>"Assisted Living"}, {"I"=>"Independent Living"}], 'direct_model_attribute' => true}},
      {'attr' => "name", 'header' => "Name", 'pos' => 1, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "street", 'header' => "Street", 'pos' => 2, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "city", 'header' => "City", 'pos' => 3, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "state", 'header' => "State", 'pos' => 4, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "postal", 'header' => "Postal", 'pos' => 5, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "phone", 'header' => "Phone", 'pos' => 6, 'definition' => {'data' => 'string'}},
    ], results[:attrs]

  end

  test "It can deal with header aliases" do
    importer = CommunityImporter.new data: <<-END
Type,Name,Address,City,State,Zip Code,Phone
AL,The Osborn,101 Theall Road,Rye,NY,10580,(914) 925-8200
AL,The Willows,459 East Oak Orchard Street,Medina,NY,14103,(585) 798-5233
    END

    results = importer.to_h

    assert_equal 2, results[:entries].length
    assert_equal [
      {'attr' => "care_type", 'header' => "Type", 'pos' => 0, 'definition' => {'data' => 'select',  'values'=>[{"A"=>"Assisted Living"}, {"I"=>"Independent Living"}], 'direct_model_attribute' => true}},
      {'attr' => "name", 'header' => "Name", 'pos' => 1, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "street", 'header' => "Address", 'pos' => 2, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "city", 'header' => "City", 'pos' => 3, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "state", 'header' => "State", 'pos' => 4, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "postal", 'header' => "Zip Code", 'pos' => 5, 'definition' => {'data' => 'string', 'direct_model_attribute' => true}},
      {'attr' => "phone", 'header' => "Phone", 'pos' => 6, 'definition' => {'data' => 'string'}},
    ], results[:attrs]
  end

  test "It can parse each line" do
    importer = CommunityImporter.new data: <<-END
Type,Name,Address,City,State,Postal,Phone
AL,The Osborn,101 Theall Road,Rye,NY,10580,(914) 925-8200
AL,The Willows,459 East Oak Orchard Street,Medina,NY,14103,(585) 798-5233
    END

    results = importer.to_h

    assert_equal 2, results[:entries].length
    assert_equal [
      {'data' => {'line_number' => 2, 'care_type' => "AL", 'name' => "The Osborn", 'street' => "101 Theall Road", 'city' => "Rye", 'state' => "NY", 'postal' => "10580", 'phone' => "(914) 925-8200"}},
      {'data' => {'line_number' => 3, 'care_type' => "AL", 'name' => "The Willows", 'street' => "459 East Oak Orchard Street", 'city' => "Medina", 'state' => "NY", 'postal' => "14103", 'phone' => "(585) 798-5233"}},
    ], results[:entries]
  end

  test "It can parse tab-separated data, and strip spaces, and quoted new lines" do
    importer = CommunityImporter.new data: <<-END
Type\tName\tAddress\tCity\tState\tPostal\tPhone\tNotes
AL\tThe Osborn\t101 Theall Road\tRye\tNY\t10580\t(914) 925-8200\t Some notes with spaces around
AL\tThe Willows\t459 East Oak Orchard Street\tMedina\tNY\t14103\t(585) 798-5233\t"Notes
in multiple lines"
    END

    results = importer.to_h

    assert_equal 2, results[:entries].length
    assert_equal [
      {'data' => {'line_number' => 2, 'care_type' => "AL", 'name' => "The Osborn", 'street' => "101 Theall Road", 'city' => "Rye", 'state' => "NY", 'postal' => "10580", 'phone' => "(914) 925-8200", 'notes' => "Some notes with spaces around"}},
      {'data' => {'line_number' => 3, 'care_type' => "AL", 'name' => "The Willows", 'street' => "459 East Oak Orchard Street", 'city' => "Medina", 'state' => "NY", 'postal' => "14103", 'phone' => "(585) 798-5233", 'notes' => "Notes\nin multiple lines"}},
    ], results[:entries]
  end

  test "It can match existing communities" do
    importer = CommunityImporter.new data: <<-END
kwid, name, address, city, state, postal, care_type, notes
, Silver Lining, 123 Broadway, New York, NY, 10001, I, Some Notes for Silver Lining
, Lining Silvers, 125 Broadway, New York, NY, 10001, I, Some Notes for other Silver Lining
#{@c5.id}, Gray Peaks, 123 Broadway, Washington, DC, 20001, I, Some Notes for Gray Peaks
, The Osborn, 101 Theall Road, Rye, NY, 10580, I, Some Notes for The Osborn
END

    results = importer.to_h

    assert_nil results[:messages]

    assert_equal [
      {'kwid' => nil, 'line_number' => 2, 'care_type' => "I", 'name' => "Silver Lining", 'street' => "123 Broadway", 'city' => "New York", 'state' => "NY", 'postal' => "10001",  'notes' => "Some Notes for Silver Lining"},
      {'kwid' => nil, 'line_number' => 3, 'care_type' => "I", 'name' => "Lining Silvers", 'street' => "125 Broadway", 'city' => "New York", 'state' => "NY", 'postal' => "10001",  'notes' => "Some Notes for other Silver Lining"},
      {'kwid' => @c5.id.to_s, 'line_number' => 4, 'care_type' => "I", 'name' => "Gray Peaks", 'street' => "123 Broadway", 'city' => "Washington", 'state' => "DC", 'postal' => "20001",  'notes' => "Some Notes for Gray Peaks"},
      {'kwid' => nil, 'line_number' => 5, 'care_type' => "I", 'name' => "The Osborn", 'street' => "101 Theall Road", 'city' => "Rye", 'state' => "NY", 'postal' => "10580",  'notes' => "Some Notes for The Osborn"},
    ], results[:entries].collect {|e| e[:data]}

    assert_equal ['name', 'geocoding', 'kwid', nil], results[:entries].collect {|e| e[:match]}

    assert_equal [
      { 'id' => @c1.id, 'status' => 'A', 'slug' => "silver-lining-independent-living-#{@c1.id}", 'name' => "Silver Lining", 'care_type' => "I", 'street' => "123 Broadway", 'city' => "New York", 'postal' => "10001", 'lat' => 40.75, 'lon' => -74.0},
      { 'id' => @c1.id, 'status' => 'A', 'slug' => "silver-lining-independent-living-#{@c1.id}", 'name' => "Silver Lining", 'care_type' => "I", 'street' => "123 Broadway", 'city' => "New York", 'postal' => "10001", 'lat' => 40.75, 'lon' => -74.0},
      { 'id' => @c5.id, 'status' => 'A', 'slug' => "gray-peaks-independent-living-#{@c5.id}", 'name' => "Gray Peaks", 'care_type' => "I", 'street' => nil, 'city' => nil, 'postal' => "20001", 'lat' => nil, 'lon' => nil},
      nil,
    ], results[:entries].collect {|e| e[:community]}
  end

  test "It can process data as CSV or as preprocessed entries" do
    importer = CommunityImporter.new data: <<-END
kwid, name, address, city, state, postal, care_type, notes
, Silver Lining, 123 Broadway, New York, NY, 10001, I, Some Notes for Silver Lining
, Lining Silvers, 125 Broadway, New York, NY, 10001, I, Some Notes for other Silver Lining
#{@c5.id}, Gray Peaks, 123 Broadway, Washington, DC, 20001, I, Some Notes for Gray Peaks
, The Osborn, 101 Theall Road, Rye, NY, 10580, I, Some Notes for The Osborn
END

    results = importer.to_h

    assert_equal [
      {'kwid' => nil, 'line_number' => 2, 'care_type' => "I", 'name' => "Silver Lining", 'street' => "123 Broadway", 'city' => "New York", 'state' => "NY", 'postal' => "10001",  'notes' => "Some Notes for Silver Lining"},
      {'kwid' => nil, 'line_number' => 3, 'care_type' => "I", 'name' => "Lining Silvers", 'street' => "125 Broadway", 'city' => "New York", 'state' => "NY", 'postal' => "10001",  'notes' => "Some Notes for other Silver Lining"},
      {'kwid' => @c5.id.to_s, 'line_number' => 4, 'care_type' => "I", 'name' => "Gray Peaks", 'street' => "123 Broadway", 'city' => "Washington", 'state' => "DC", 'postal' => "20001",  'notes' => "Some Notes for Gray Peaks"},
      {'kwid' => nil, 'line_number' => 5, 'care_type' => "I", 'name' => "The Osborn", 'street' => "101 Theall Road", 'city' => "Rye", 'state' => "NY", 'postal' => "10580",  'notes' => "Some Notes for The Osborn"},
    ], results[:entries].collect {|e| e[:data]}

    assert_equal ['name', 'geocoding', 'kwid', nil], results[:entries].collect {|e| e[:match]}

    assert_equal [
      { 'id' => @c1.id, 'status' => 'A', 'slug' => "silver-lining-independent-living-#{@c1.id}", 'name' => "Silver Lining", 'care_type' => "I", 'street' => "123 Broadway", 'city' => "New York", 'postal' => "10001", 'lat' => 40.75, 'lon' => -74.0},
      { 'id' => @c1.id, 'status' => 'A', 'slug' => "silver-lining-independent-living-#{@c1.id}", 'name' => "Silver Lining", 'care_type' => "I", 'street' => "123 Broadway", 'city' => "New York", 'postal' => "10001", 'lat' => 40.75, 'lon' => -74.0},
      { 'id' => @c5.id, 'status' => 'A', 'slug' => "gray-peaks-independent-living-#{@c5.id}", 'name' => "Gray Peaks", 'care_type' => "I", 'street' => nil, 'city' => nil, 'postal' => "20001", 'lat' => nil, 'lon' => nil},
      nil,
    ], results[:entries].collect {|e| e[:community]}

    # Lets rinse and repeat...
    importer2 = CommunityImporter.new results

    results2 = importer2.to_h

    assert_equal [
      {'kwid' => nil, 'line_number' => 2, 'care_type' => "I", 'name' => "Silver Lining", 'street' => "123 Broadway", 'city' => "New York", 'state' => "NY", 'postal' => "10001",  'notes' => "Some Notes for Silver Lining"},
      {'kwid' => nil, 'line_number' => 3, 'care_type' => "I", 'name' => "Lining Silvers", 'street' => "125 Broadway", 'city' => "New York", 'state' => "NY", 'postal' => "10001",  'notes' => "Some Notes for other Silver Lining"},
      {'kwid' => @c5.id.to_s, 'line_number' => 4, 'care_type' => "I", 'name' => "Gray Peaks", 'street' => "123 Broadway", 'city' => "Washington", 'state' => "DC", 'postal' => "20001",  'notes' => "Some Notes for Gray Peaks"},
      {'kwid' => nil, 'line_number' => 5, 'care_type' => "I", 'name' => "The Osborn", 'street' => "101 Theall Road", 'city' => "Rye", 'state' => "NY", 'postal' => "10580",  'notes' => "Some Notes for The Osborn"},
    ], results2[:entries].collect {|e| e[:data]}

    assert_equal ['name', 'geocoding', 'kwid', nil], results2[:entries].collect {|e| e[:match]}

    assert_equal [
      { 'id' => @c1.id, 'status' => 'A', 'slug' => "silver-lining-independent-living-#{@c1.id}", 'name' => "Silver Lining", 'care_type' => "I", 'street' => "123 Broadway", 'city' => "New York", 'postal' => "10001", 'lat' => 40.75, 'lon' => -74.0},
      { 'id' => @c1.id, 'status' => 'A', 'slug' => "silver-lining-independent-living-#{@c1.id}", 'name' => "Silver Lining", 'care_type' => "I", 'street' => "123 Broadway", 'city' => "New York", 'postal' => "10001", 'lat' => 40.75, 'lon' => -74.0},
      { 'id' => @c5.id, 'status' => 'A', 'slug' => "gray-peaks-independent-living-#{@c5.id}", 'name' => "Gray Peaks", 'care_type' => "I", 'street' => nil, 'city' => nil, 'postal' => "20001", 'lat' => nil, 'lon' => nil},
      nil,
    ], results2[:entries].collect {|e| e[:community]}

  end

  test "It can compare with existing data" do
    @c1.data[:star_rating] = 2; @c1.data[:pool] = true; @c1.save
    @c5.data[:star_rating] = 3; @c5.data[:pool] = true; @c5.save

    importer = CommunityImporter.new data: <<-END
kwid, name, star_rating, pool
#{@c1.id}, Silver Lining, 5, yes
#{@c5.id}, Gray Peaks, 3, FALSE
END

    importer.compare

    results = importer.to_h

    assert_equal [
      {'kwid' => @c1.id.to_s, 'line_number' => 2, 'name' => "Silver Lining", 'star_rating' => 5, 'pool' => true},
      {'kwid' => @c5.id.to_s, 'line_number' => 3, 'name' => "Gray Peaks", 'star_rating' => 3, 'pool' => false},
    ], results[:entries].collect {|e| e[:data]}

    assert_equal [{'star_rating' => 2}, {'pool' => true}], results[:entries].collect {|e| e[:diffs]}
  end

  test "It can update existing data and create new communities" do
    @c1.data[:star_rating] = 2; @c1.data[:pool] = true; @c1.save
    @c5.data[:star_rating] = 3; @c5.data[:pool] = true; @c5.save

    importer = CommunityImporter.new data: <<-END
kwid, name, care_type, street, city, state, postal, star_rating, pool
, Silver Lining, I,,,, 10001, 5, yes
#{@c5.id}, Gray Peaks, I,,,, 20001, 3, FALSE
create, The Osborn, I, 101 Theall Road, Rye, NY, 10580, 4, false
END

    importer.import

    results = importer.to_h

    c6 = Community.find_by_name("The Osborn")
    assert_equal "101 Theall Road", c6.street
    assert_equal '0', c6.data['completeness']
    assert_equal true, c6.data['needs_review']

    entries = results[:entries].collect {|e| e[:data]}
    assert_hashes_equal({'kwid' => nil, 'line_number' => 2, 'name' => "Silver Lining", 'care_type' => 'I', 'star_rating' => 5, 'pool' => true, 'street' => nil, 'city' => nil, 'state' => nil, 'postal' => "10001"}, entries[0])
    assert_hashes_equal({'kwid' => @c5.id.to_s, 'line_number' => 3, 'name' => "Gray Peaks", 'care_type' => 'I', 'star_rating' => 3, 'pool' => false, 'street' => nil, 'city' => nil, 'state' => nil, 'postal' => "20001"}, entries[1])
    assert_hashes_equal({'kwid' => "create", 'line_number' => 4, 'name' => "The Osborn", 'care_type' => 'I', 'star_rating' => 4, 'pool' => false, 'street' => "101 Theall Road", 'city' => "Rye", 'state' => "NY", 'postal' => "10580"}, entries[2])

    assert_equal([true, true, true], results[:entries].collect {|e| e[:saved]})
    assert_equal([nil, nil, true], results[:entries].collect {|e| e[:is_new]})
  end
end
