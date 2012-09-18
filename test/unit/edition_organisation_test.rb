require 'test_helper'

class EditionOrganisationTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test "should be invalid if the edition has been marked as featured but no image has been uploaded" do
    edition_organisation = build(:edition_organisation, featured: true)
    refute edition_organisation.valid?
    assert edition_organisation.errors[:image].present?
  end

  test "should build an image using nested attributes" do
    edition_organisation = build(:edition_organisation)
    edition_organisation.image_attributes = {
      file: fixture_file_upload('minister-of-funk.jpg')
    }
    edition_organisation.save!

    edition_organisation = EditionOrganisation.find(edition_organisation.id)

    assert_match /minister-of-funk/, edition_organisation.image.file.url
  end

  test "should not build an image if the nested attributes are empty" do
    edition_organisation = build(:edition_organisation)
    edition_organisation.image_attributes = {}
    edition_organisation.save!

    edition_organisation = EditionOrganisation.find(edition_organisation.id)

    assert_nil edition_organisation.image
  end
end