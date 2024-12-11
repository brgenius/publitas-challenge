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

Ensure you have a Ruby environment (e.g., Ruby on Rails) set up.
Dependencies:

`$ bundle install`

### Execution:

Run the script, specifying the feed file path (either a Publitas feed URL or a local file path):



```$ ruby publitas_feed_processor.rb <feed_file_xml_url>```

Replace <feed_file_xml_url> with the actual path to your Publitas feed or local XML file.
Eg:

```$ ruby assignment.rb http://challenge.publitas.com/feed.xml```
