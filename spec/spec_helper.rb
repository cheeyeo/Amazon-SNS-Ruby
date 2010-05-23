$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'spec'
require 'spec/autorun'
require 'request'
require 'amaze_sns'
require 'eventmachine'
require 'em-http'
require 'em-http/mock'

Spec::Runner.configure do |config|
  # EventMachine.instance_eval do
  #         # Switching out EM's defer since it makes tests just a tad more unreliable
  #         alias :defer_original :defer
  #         def defer
  #           yield
  #         end
  #       end unless EM.respond_to?(:defer_original)
  #       
  #   
  #   def run_in_em_loop
  #     EM.run {
  #       yield
  #     }
  #   end
  #   
  #   class Request
  #         self.module_eval do
  #           def http_class
  #             EventMachine::MockHttpRequest
  #           end
  #         end
  #       end


def fake_response
  <<-HEREDOC
<ListTopicsResponse xmlns=\"http://sns.amazonaws.com/doc/2010-03-31/\">\n<ListTopicsResult>\n<Topics>\n<member>\n<TopicArn>arn:aws:sns:us-east-1:365155214602:cars</TopicArn>\n</member>\n<member>\n<TopicArn>arn:aws:sns:us-east-1:365155214602:luckypooz</TopicArn>\n</member>\n<member>\n<TopicArn>arn:aws:sns:us-east-1:365155214602:29steps_products</TopicArn>\n</member>\n</Topics>\n</ListTopicsResult>\n <ResponseMetadata>\n<RequestId>d4a2ff9b-56dc-11df-b6e7-a7864eff589e</RequestId>\n</ResponseMetadata>\n</ListTopicsResponse>
HEREDOC
end
  
  

  
end #end configure



