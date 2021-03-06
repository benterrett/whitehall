Feature: Unpublishing published documents
  As a GDS Editor
  I want to be able to revert published documents back to the draft state
  So that I can remove documents from the site that were published in error

  Scenario: Unpublishing a published document
    Given I am a GDS editor
    And a published document "Published by accident" exists
    When I unpublish the document "Published by accident"
    Then the document "Published by accident" should not be visible to the public