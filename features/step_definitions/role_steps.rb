When /^I add a new "([^"]*)" role named "([^"]*)" to the "([^"]*)"$/ do |role_type, role_name, organisation_name|
  @role_name = role_name

  visit admin_roles_path
  click_on "Create Role"
  fill_in "Name", with: role_name
  select role_type, from: "Type"
  select organisation_name, from: "Organisations"
  click_on "Save"
end

Then /^I should be able to appoint "([^"]*)" to the new role$/ do |person_name|
  click_on @role_name
  click_on "New appointment"
  select person_name, from: "Person"
  select_date "Started at", with: 1.day.ago.to_s
  click_on "Save"
end

Then /^I should see "([^"]*)" listed on the "([^"]*)" organisation page$/ do |person_name, organisation_name|
  visit_organisation organisation_name
  role = find_person(person_name).roles.first
  assert page.has_css?(record_css_selector(role))
end
