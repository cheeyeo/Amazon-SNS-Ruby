Amazon SNS gem
==============

Introduction
---------
A Ruby gem for use with the Amazon Simple Notification service (http://aws.amazon.com/sns/).

Usage
---------------

AmazeSNS.skey = <your amazon aws secret key>

AmazeSNS.akey = <your amazon aws access key>

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
---------------
The specs are partly working at the moment as the gem is still under development

The gem itself has been tested on systems running ruby 1.8.6, 1.8.7, 1.9.2



Copyright
---------

Copyright (c) 2010 29 Steps UK. See LICENSE for details.