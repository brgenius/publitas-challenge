![alt text](https://raw.githubusercontent.com/brgenius/publitas-challenge/main/history.gif 'Publitas feed processor gource video history')

# Publitas Feed Processor

This Ruby program efficiently extracts item from a Publitas feed (XML format) or a local XML file and sends them to an external service for further processing.

## What it Does:

### Batch Size Optimization:

It employs a binary search-like approach to identify batches of item indexes within the Publitas feed.
These batches are constrained by a size limit (default 5MB) to ensure efficient processing by the external service.
The search prioritizes finding batches close to the size limit for faster processing.

### XML Handling:

The program leverages the `nokogiri` gem to parse the XML feed.
It utilizes XPath queries to efficiently locate relevant elements within the feed.

### Parallelism:

It also uses `async` gem to parallelize the external service call
Why This Approach:

### Performance:

Binary search-like optimization significantly improves processing speed compared to sequential search.

### Efficiency:

Focusing on batches close to the size limit reduces potential wasted processing cycles.

### Flexibility:

The program can work with both Publitas feeds and local XML files.

## Usage:

### Ruby Environment:

Ensure you have a Ruby environment `2.7.8` set up.
Dependencies:

`$ bundle install`

### Execution:

Run the script, replacing the given url with the actual path to your Publitas feed or without the url in order to use the local XML file. 

`ruby assignment.rb http://challenge.publitas.com/feed.xml #remote file execution`
or
`ruby assignment.rb #local feed.xml execution`
