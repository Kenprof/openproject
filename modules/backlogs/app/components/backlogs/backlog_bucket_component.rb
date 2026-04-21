# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module Backlogs
  class BacklogBucketComponent < ApplicationComponent
    include Primer::AttributesHelper
    include OpTurbo::Streamable
    include Backlogs::CommonHelper

    attr_reader :backlog_bucket, :project, :work_packages, :current_user

    def initialize(backlog_bucket:, project:, current_user: User.current, **system_arguments)
      super()

      @backlog_bucket = backlog_bucket
      @project = project
      @current_user = current_user
      @work_packages = backlog_bucket.work_packages

      @system_arguments = system_arguments
      @system_arguments[:id] = dom_id(backlog_bucket)
      @system_arguments[:list_id] = "#{@system_arguments[:id]}-list"
      @system_arguments[:padding] = :condensed
      @system_arguments[:data] = merge_data(
        @system_arguments,
        { data: drop_target_config },
        { data: { test_selector: "backlog-bucket-#{backlog_bucket.id}" } }
      )
    end

    def wrapper_uniq_by
      backlog_bucket.id
    end

    private

    def folded?
      current_user.pref[:backlogs_versions_default_fold_state] == "closed"
    end

    def drop_target_config
      {
        generic_drag_and_drop_target: "container",
        target_container_accessor: ":scope > ul",
        target_id: backlog_bucket.persisted? ? "backlog_bucket:#{backlog_bucket.id}" : "inbox",
        target_allowed_drag_type: "story"
      }
    end

    def work_package_classes_attribute
      classes = "Box-row--hover-blue Box-row--focus-gray Box-row--clickable"

      if work_package_draggable?
        classes += " Box-row--draggable"
      end

      classes
    end

    def work_package_data_attribute(work_package)
      draggable_item_config(work_package).merge(
        story: true,
        controller: "backlogs--story",
        backlogs__story_id_value: story.id,
        backlogs__story_split_url_value: project_backlogs_backlog_details_path(project, story),
        backlogs__story_full_url_value: work_package_path(story),
        backlogs__story_selected_class: "Box-row--blue",
        test_selector: card_test_selector(story)
      )
    end

    def draggable_item_config(story)
      return {} unless work_package_draggable?

      {
        draggable_id: story.id,
        draggable_type: "story",
        drop_url: move_project_backlogs_work_package_path(project, backlog_bucket_id: backlog_bucket.id, id: story.id)
      }
    end

    def card_test_selector(story)
      "work-package-#{story.id}"
    end

    def work_package_draggable?
      current_user.allowed_in_project?(:manage_sprint_items, project)
    end
  end
end
