class EditionOrganisation < ActiveRecord::Base
  belongs_to :edition
  belongs_to :organisation
  belongs_to :image, class_name: 'EditionOrganisationImageData', foreign_key: :edition_organisation_image_data_id

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :image, presence: true, if: :featured?
end