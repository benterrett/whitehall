Feature: Fact checking policies
  In order to ensure we're not publishing any inaccuracies in our policies
  As a user who is allowed to request fact checks
  I want to request fact checking of a draft policy

Scenario: Policy writer requests fact checking
  Given I am logged in as a policy writer
  And I have drafted a policy
  When I request that "fact-checker@example.com" fact checks the policy
  Then "fact-checker@example.com" should receive an email requesting fact checking

Scenario: Departmental editor requests fact checking
  Given I am logged in as a departmental editor
  And I have drafted a policy
  When I request that "fact-checker@example.com" fact checks the policy
  Then "fact-checker@example.com" should receive an email requesting fact checking

Scenario: Fact checker views the draft policy
  Given "fact-checker@example.com" has received an email requesting they fact check a draft policy titled "Check me"
  When "fact-checker@example.com" clicks the email link to the draft policy
  Then they should see the draft policy titled "Check me"

Scenario: Fact checker enters feedback
  Given "fact-checker@example.com" has received an email requesting they fact check a draft policy titled "Check me"
  When "fact-checker@example.com" clicks the email link to the draft policy
  And they provide feedback "We cannot establish the moral character of all dogs"
  Then they should be notified "Your feedback has been saved"

Scenario: Reviewing fact checker comments
  Given "fact-checker@example.com" has received an email requesting they fact check a draft policy titled "Check me"
  And "fact-checker@example.com" clicks the email link to the draft policy
  And they provide feedback "We cannot establish the moral character of all dogs"
  When I am logged in as a policy writer
  And I visit the list of draft policies
  And I click edit for the policy "Check me"
  Then I should see the fact checking feedback "We cannot establish the moral character of all dogs"