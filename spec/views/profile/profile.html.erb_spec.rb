#
# Copyright (C) 2011 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../views_helper')

describe "/profile/profile" do
  it "should render" do
    course_with_student
    view_context

    assigns[:user] = @user
    assigns[:email_channels] = []
    assigns[:other_channels] = []
    assigns[:sms_channels] = []
    assigns[:notification_categories] = Notification.dashboard_categories
    assigns[:policies] = @user.notification_policies
    assigns[:default_pseudonym] = @user.pseudonyms.create!(:unique_id => "unique@example.com", :password => "asdfaa", :password_confirmation => "asdfaa")
    assigns[:pseudonyms] = @user.pseudonyms
    assigns[:password_pseudonyms] = []
    render "profile/profile"
    response.should_not be_nil
  end

  it "should not show the delete link for SIS pseudonyms" do
    course_with_student
    view_context

    assigns[:user] = @user
    assigns[:email_channels] = []
    assigns[:other_channels] = []
    assigns[:sms_channels] = []
    assigns[:notification_categories] = Notification.dashboard_categories
    assigns[:policies] = @user.notification_policies
    default_pseudonym = assigns[:default_pseudonym] = @user.pseudonyms.create!(:unique_id => "unique@example.com", :password => "asdfaa", :password_confirmation => "asdfaa")
    sis_pseudonym = @user.pseudonyms.create!(:unique_id => 'sis_unique@example.com') { |p| p.sis_user_id = 'sis_id' }
    assigns[:pseudonyms] = @user.pseudonyms
    assigns[:password_pseudonyms] = []
    render "profile/profile"
    page = Nokogiri('<document>' + response.body + '</document>')
    page.css("#pseudonym_#{default_pseudonym.id} .delete_pseudonym_link").first['style'].should == ''
    page.css("#pseudonym_#{sis_pseudonym.id} .delete_pseudonym_link").first['style'].should == 'display: none;'
  end
end

