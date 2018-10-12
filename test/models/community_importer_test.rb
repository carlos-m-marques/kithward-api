require 'test_helper'

class CommunityImporterTest < ActiveSupport::TestCase
  test "It recognizes when there is no data" do
    importer = CommunityImporter.new ""

    assert_equal [], importer.to_h[:entries]
    assert_equal [{message: "No data!"}], importer.to_h[:errors]
  end

  test "It processes the headers" do
    importer = CommunityImporter.new <<-END
Care Type,Name,Street,City,State,Postal,Phone
AL,The Osborn,101 Theall Road,Rye,NY,10580,(914) 925-8200
AL,The Willows,459 East Oak Orchard Street,Medina,NY,14103,(585) 798-5233
    END

    assert_equal 2, importer.to_h[:entries].length
    assert_equal [
      {'attr' => "care_type", 'header' => "Care Type", 'pos' => 0},
      {'attr' => "name", 'header' => "Name", 'pos' => 1},
      {'attr' => "street", 'header' => "Street", 'pos' => 2},
      {'attr' => "city", 'header' => "City", 'pos' => 3},
      {'attr' => "state", 'header' => "State", 'pos' => 4},
      {'attr' => "postal", 'header' => "Postal", 'pos' => 5},
      {'attr' => "phone", 'header' => "Phone", 'pos' => 6}
    ], importer.to_h[:attrs]

  end

  test "It can deal with header aliases" do
    importer = CommunityImporter.new <<-END
Type,Name,Address,City,State,Zip Code,Phone
AL,The Osborn,101 Theall Road,Rye,NY,10580,(914) 925-8200
AL,The Willows,459 East Oak Orchard Street,Medina,NY,14103,(585) 798-5233
    END

    assert_equal 2, importer.to_h[:entries].length
    assert_equal [
      {'attr' => "care_type", 'header' => "Type", 'pos' => 0},
      {'attr' => "name", 'header' => "Name", 'pos' => 1},
      {'attr' => "street", 'header' => "Address", 'pos' => 2},
      {'attr' => "city", 'header' => "City", 'pos' => 3},
      {'attr' => "state", 'header' => "State", 'pos' => 4},
      {'attr' => "postal", 'header' => "Zip Code", 'pos' => 5},
      {'attr' => "phone", 'header' => "Phone", 'pos' => 6}
    ], importer.to_h[:attrs]
  end

  test "It can parse each line" do
    importer = CommunityImporter.new <<-END
Type,Name,Address,City,State,Postal,Phone
AL,The Osborn,101 Theall Road,Rye,NY,10580,(914) 925-8200
AL,The Willows,459 East Oak Orchard Street,Medina,NY,14103,(585) 798-5233
    END

    assert_equal 2, importer.to_h[:entries].length
    assert_equal [
      {'line_number' => 2, 'care_type' => "AL", 'name' => "The Osborn", 'street' => "101 Theall Road", 'city' => "Rye", 'state' => "NY", 'postal' => "10580", 'phone' => "(914) 925-8200"},
      {'line_number' => 3, 'care_type' => "AL", 'name' => "The Willows", 'street' => "459 East Oak Orchard Street", 'city' => "Medina", 'state' => "NY", 'postal' => "14103", 'phone' => "(585) 798-5233"},
    ], importer.to_h[:entries]
  end
end
