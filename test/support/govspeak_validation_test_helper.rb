module GovspeakValidationTestHelper
  def should_protect_against_xss_and_content_attacks_on(*attributes)
    attributes.each do |attribute|
      test "should protect against XSS and content attacks via #{attribute}" do
        object = build(factory_name_from_test, attribute => "<script>badThings();</script>")
        refute object.valid?, "should be invalid with unsafe content"
        assert object.errors[attribute].include?("cannot include invalid formatting or JavaScript"), "didn't add validation errors to #{attribute} attribute"
      end
    end
  end
end
