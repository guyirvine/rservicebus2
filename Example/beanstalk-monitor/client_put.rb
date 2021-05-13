require 'beanstalk-client'

beanstalk = Beanstalk::Pool.new(['localhost:11_300'])
beanstalk.use('GuysTmpQueue')
beanstalk.put('Guys Message')
