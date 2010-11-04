Amazon SNS gem
==============

Introduction
------------

A Ruby gem for use with the Amazon Simple Notification service (http://aws.amazon.com/sns/).

Usage
------

### Quickstart Guide ###

  `gem install amaze_sns`

  require 'amaze-sns'

  AmazeSNS.skey = 'your amazon aws secret key'

  AmazeSNS.akey = 'your amazon aws access key'

  AmazeSNS['your_topic_name'] # creates a new Topic Object but not yet published
  AmazeSNS['your_topic_name'].create # add new topic to local hash and to SNS
  AmazeSNS['your_topic_name'].delete # removes it from both SNS and local hash

  AmazeSNS.logger = my_logger # set a logger for the response


Dependencies
---------------

Require the CrackXML gem for parsing XML responses back from SNS; EventMachine
and EM-Http request gem for the requests; and ruby hmac gem for authenticating with Amazon Web Services

For Ruby 1.9.2 users, if you are having errors, please check that your em-http-request gem version is not
higher than 0.2.10 although the gemspec has been updated to reflect this


Tests
------
The specs are partly working at the moment as the gem is still under development

The gem itself has been tested on systems running ruby 1.8.6, 1.8.7, 1.9.2


License
-------

(The MIT License)

Copyright © 2010 Chee Yeo, 29 Steps UK

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
