require "test_helper"

class DftPublicationWithJsonImportTest < ActiveSupport::TestCase
  test "imports CSV in DFT format (including JSON attachments) into database" do
    creator = User.create!(name: "Automatic Data Importer")
    organisation = create(:organisation_with_alternative_format_contact_email, name: "department-for-transport")
    policy = create(:policy, title: "managing-improving-and-investing-in-the-road-network")
    stub_request(:get, "http://assets.dft.gov.uk/publications/a5m1-dunstable-norther-bypass/inspector-report.pdf").to_return(body: "attachment-content")

    data = File.read(Rails.root.join("test/fixtures/dft_publication_import_with_json_test.csv"))
    PublicationUploader.new(csv_data: data).upload

    publication = Publication.first
    refute_nil publication

    assert_equal creator, publication.creator
    assert_equal [organisation], publication.organisations
    assert_equal [policy], publication.related_policies

    assert_equal 1, publication.attachments.size
    attachment = publication.attachments.first
    assert_equal "attachment-content", File.read(attachment.file.path)
  end
end
