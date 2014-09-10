# BDWM 关键词订阅服务

### For development

0. `bundle install`
1. `cp config/config.sample.yml config/sample.yml` and make your own one.
2. `bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed`
3. `bundle exec rake s`

### For production

0. `bundle install`
1. `cp config/config.sample.yml config/sample.yml` and make your own one.
2. `bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed`
3. `bundle exec rake nginx:setup && sudo ln -sfn $(pwd)/config/nginx.conf /etc/nginx/sites-enabled/bdwm`
4. restart nginx and `bundle exec thin start --socket /tmp/bdwm_subscriber.sock -e production -d`
5. `bundle exec whenever -w` # write crontab if you want
