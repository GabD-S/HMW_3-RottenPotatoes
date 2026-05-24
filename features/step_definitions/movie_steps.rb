ALL_RATINGS = %w[G PG PG-13 R].freeze

Given /^the following movies exist:?$/ do |movies_table|
  movies_table.hashes.each do |row|
    Movie.create!(
      title: row['title'],
      rating: row['rating'],
      release_date: Date.parse(row['release_date']),
      description: row['description']
    )
  end
end

When /^I check the following ratings: (.*)$/ do |rating_list|
  rating_list.split(/\s*,\s*/).each do |rating|
    step %(I check "ratings_#{rating}")
  end
end

When /^I uncheck the following ratings: (.*)$/ do |rating_list|
  rating_list.split(/\s*,\s*/).each do |rating|
    step %(I uncheck "ratings_#{rating}")
  end
end

When /^I check all ratings$/ do
  ALL_RATINGS.each { |r| step %(I check "ratings_#{r}") }
end

Then /^I should see all of the movies$/ do
  rows = page.all('table#movies tbody tr').count
  expect(rows).to eq(Movie.count)
end

Then /^I should see "([^"]+)" before "([^"]+)"$/ do |first, second|
  expect(page.body).to match(/#{Regexp.escape(first)}.*#{Regexp.escape(second)}/m)
end
