Given /^a policy area called "([^"]*)" with description "([^"]*)"$/ do |name, description|
  create(:topic, name: name, description: description)
end

When /^I create a new policy area "([^"]*)" with description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Policy Areas"
  click_link "Create Policy Area"
  fill_in "Name", with: name
  fill_in "Description", with: description
  click_button "Save"
end

When /^I edit the policy area "([^"]*)" to have description "([^"]*)"$/ do |name, description|
  visit admin_root_path
  click_link "Policy Areas"
  click_link name
  fill_in "Description", with: description
  click_button "Save"
end

Then /^I should see the "([^"]*)" policy area description is "([^"]*)"$/ do |name, description|
  visit topics_path
  click_link name
  assert page.has_css?(".description", text: description)
end

Then /^I should see in the admin the "([^"]*)" policy area description is "([^"]*)"$/ do |name, description|
  visit admin_topics_path
  assert page.has_css?(".name", text: name)
  assert page.has_css?(".description", text: description)
end

Then /^I should be able to delete the policy area "([^"]*)"$/ do |name|
  visit admin_topics_path
  click_link name
  click_button 'Delete'
end

Given /^the policy area "([^"]*)" contains some policies$/ do |name|
  documents = Array.new(5) { build(:published_policy) } + Array.new(2) { build(:draft_policy) }
  create(:topic, name: name, documents: documents)
end

Given /^two policy areas "([^"]*)" and "([^"]*)" exist$/ do |first_topic, second_topic|
  create(:topic, name: first_topic)
  create(:topic, name: second_topic)
end

Given /^other policy areas also have policies$/ do
  create(:topic, documents: [build(:published_policy)])
  create(:topic, documents: [build(:published_policy)])
end

When /^I visit the list of policy areas$/ do
  visit topics_path
end

When /^I visit the "([^"]*)" policy area$/ do |name|
  topic = Topic.find_by_name!(name)
  visit topic_path(topic)
end

When /^I set the order of the policies in the "([^"]*)" policy area to:$/ do |name, table|
  topic = Topic.find_by_name!(name)
  visit edit_admin_topic_path(topic)
  table.rows.each_with_index do |(policy_name), index|
    fill_in policy_name, with: index
  end
  click_button "Save"
end

When /^I set the featured policies in the "([^"]*)" policy area to:$/ do |name, table|
  topic = Topic.find_by_name!(name)
  visit edit_admin_topic_path(topic)
  table.rows.each_with_index do |(policy_name), index|
    policy = Policy.find_by_title(policy_name)
    within record_css_selector(policy) do
      check "Featured?"
    end
  end
  click_button "Save"
end

Then /^I should see the featured policies in the "([^"]*)" policy area are:$/ do |name, expected_table|
  topic = Topic.find_by_name!(name)
  visit topic_path(topic)
  rows = find("ul.featured.policies").all('li')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see the order of the policies in the "([^"]*)" policy area is:$/ do |name, expected_table|
  topic = Topic.find_by_name!(name)
  visit topic_path(topic)
  rows = find("#policies ul.policies").all('li')
  table = rows.map { |r| r.all('a').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should only see published policies belonging to the "([^"]*)" policy area$/ do |name|
  topic = Topic.find_by_name!(name)
  documents = records_from_elements(Document, page.all(".document"))
  assert documents.all? { |document| topic.documents.published.include?(document) }
end

Then /^I should see the policy areas "([^"]*)" and "([^"]*)"$/ do |first_topic_name, second_topic_name|
  first_topic = Topic.find_by_name!(first_topic_name)
  second_topic = Topic.find_by_name!(second_topic_name)
  assert page.has_css?(record_css_selector(first_topic), text: first_topic_name)
  assert page.has_css?(record_css_selector(second_topic), text: second_topic_name)
end

Then /^I should see links to the "([^"]*)" and "([^"]*)" policy areas$/ do |topic_1_name, topic_2_name|
  topic_1 = Topic.find_by_name!(topic_1_name)
  topic_2 = Topic.find_by_name!(topic_2_name)
  assert page.has_css?("a[href='#{topic_path(topic_1)}']", text: topic_1_name)
  assert page.has_css?("a[href='#{topic_path(topic_2)}']", text: topic_2_name)
end