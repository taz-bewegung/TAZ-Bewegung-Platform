class SetupOldSchema < ActiveRecord::Migration
  def change

    create_table "activities", :id => false, :force => true do |t|
      t.string   "uuid",                 :limit => 36
      t.string   "title"
      t.string   "permalink"
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.datetime "activated_at"
      t.text     "description"
      t.string   "owner_id"
      t.string   "user_id"
      t.string   "event_id"
      t.string   "activity_category_id"
      t.string   "state",                              :default => "passive"
      t.boolean  "attendable"
      t.boolean  "multi_bloggable"
      t.text     "email_message"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "owner_type"
      t.string   "activated_by"
      t.text     "admin_comment"
      t.string   "location_id"
      t.string   "activity_type"
      t.boolean  "continuous",                         :default => false
      t.string   "website"
      t.datetime "deleted_at"
      t.text     "goal"
      t.text     "participation"
      t.string   "commentable",                        :default => "1"
    end

    add_index "activities", ["activity_category_id"], :name => "index_activities_on_activity_category_id"
    add_index "activities", ["event_id"], :name => "index_activities_on_event_id"
    add_index "activities", ["owner_id"], :name => "index_activities_on_owner_id"
    add_index "activities", ["owner_type"], :name => "index_activities_on_owner_type"
    add_index "activities", ["permalink"], :name => "index_activities_on_permalink"
    add_index "activities", ["user_id"], :name => "index_activities_on_user_id"
    add_index "activities", ["uuid"], :name => "index_activities_on_uuid", :unique => true

    create_table "activity_categories", :id => false, :force => true do |t|
      t.string   "uuid",        :limit => 36
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "elargio_id"
    end

    add_index "activity_categories", ["uuid"], :name => "index_activity_categories_on_uuid", :unique => true

    create_table "activity_category_images", :id => false, :force => true do |t|
      t.string   "uuid",                 :limit => 36
      t.string   "filename"
      t.string   "content_type"
      t.string   "size"
      t.string   "width"
      t.string   "height"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.string   "activity_category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "activity_event_memberships", :id => false, :force => true do |t|
      t.string   "uuid",        :limit => 36
      t.string   "activity_id"
      t.string   "event_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "activity_memberships", :id => false, :force => true do |t|
      t.string   "uuid",          :limit => 36
      t.string   "user_id"
      t.string   "activity_id"
      t.text     "message"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "activity_type"
    end

    add_index "activity_memberships", ["activity_id"], :name => "index_activity_memberships_on_activity_id"
    add_index "activity_memberships", ["user_id"], :name => "index_activity_memberships_on_user_id"
    add_index "activity_memberships", ["uuid"], :name => "index_activity_memberships_on_uuid", :unique => true

    create_table "activity_sponsors", :id => false, :force => true do |t|
      t.string   "uuid",        :limit => 36
      t.string   "name"
      t.text     "description"
      t.string   "website"
      t.string   "user_id"
      t.string   "activity_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "elargio_id"
    end

    add_index "activity_sponsors", ["activity_id"], :name => "index_activity_sponsors_on_activity_id"
    add_index "activity_sponsors", ["user_id"], :name => "index_activity_sponsors_on_user_id"
    add_index "activity_sponsors", ["uuid"], :name => "index_activity_sponsors_on_uuid", :unique => true

    create_table "addresses", :id => false, :force => true do |t|
      t.string   "uuid",              :limit => 36
      t.string   "street"
      t.string   "zip_code"
      t.string   "city"
      t.string   "country_code"
      t.string   "geocode_precision"
      t.string   "lat"
      t.string   "lng"
      t.string   "addressable_type"
      t.string   "addressable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state"
      t.datetime "deleted_at"
      t.boolean  "nationwide",                      :default => false
      t.string   "name"
    end

    add_index "addresses", ["addressable_id"], :name => "index_addresses_on_addressable_id"
    add_index "addresses", ["addressable_type"], :name => "index_addresses_on_addressable_type"
    add_index "addresses", ["uuid"], :name => "index_addresses_on_uuid", :unique => true

    create_table "admin_texts", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "bdrb_job_queues", :force => true do |t|
      t.binary   "args"
      t.string   "worker_name"
      t.string   "worker_method"
      t.string   "job_key"
      t.integer  "taken"
      t.integer  "finished"
      t.integer  "timeout"
      t.integer  "priority"
      t.datetime "submitted_at"
      t.datetime "started_at"
      t.datetime "finished_at"
      t.datetime "archived_at"
      t.string   "tag"
      t.string   "submitter_info"
      t.string   "runner_info"
      t.string   "worker_key"
      t.datetime "scheduled_at"
    end

    create_table "beta_signups", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "email"
      t.string   "name"
      t.text     "comment"
      t.string   "ip"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "code"
    end

    create_table "blog_content_images", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "title"
      t.string   "filename"
      t.string   "content_type"
      t.string   "size"
      t.string   "width"
      t.string   "height"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "blog_content_texts", :id => false, :force => true do |t|
      t.string   "uuid",            :limit => 36
      t.text     "bodytext"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "image_alignment"
      t.datetime "deleted_at"
    end

    create_table "blog_content_video_with_codes", :id => false, :force => true do |t|
      t.text     "code"
      t.string   "uuid",       :limit => 36
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "blog_content_videos", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "title"
      t.string   "video_url"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
    end

    create_table "blog_messages", :id => false, :force => true do |t|
      t.string   "uuid",            :limit => 36
      t.string   "title"
      t.string   "blog_type"
      t.string   "blog_id"
      t.string   "user_id"
      t.string   "video_url"
      t.text     "message"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "elargio_id"
      t.string   "elargio_blog_id"
    end

    add_index "blog_messages", ["blog_id"], :name => "index_blog_messages_on_blog_id"
    add_index "blog_messages", ["blog_type"], :name => "index_blog_messages_on_blog_type"
    add_index "blog_messages", ["user_id"], :name => "index_blog_messages_on_user_id"
    add_index "blog_messages", ["uuid"], :name => "index_blog_messages_on_uuid", :unique => true

    create_table "blog_post_contents", :id => false, :force => true do |t|
      t.string   "uuid",             :limit => 36
      t.integer  "position"
      t.string   "contentable_id"
      t.string   "contentable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "blog_post_id"
      t.datetime "deleted_at"
    end

    create_table "blog_posts", :id => false, :force => true do |t|
      t.string   "uuid",                     :limit => 36
      t.string   "blog_id"
      t.string   "blogger_id"
      t.string   "blogger_type"
      t.string   "title"
      t.integer  "blog_post_comments_count",               :default => 0,     :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "commentable"
      t.string   "state"
      t.string   "temp_tag_list"
      t.string   "permalink"
      t.datetime "deleted_at"
      t.datetime "published_at"
      t.boolean  "synced",                                 :default => false
    end

    create_table "blogs", :id => false, :force => true do |t|
      t.string   "uuid",           :limit => 36
      t.string   "bloggable_id"
      t.string   "bloggable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
    end

    create_table "bookmarks", :id => false, :force => true do |t|
      t.string   "uuid",              :limit => 36
      t.string   "user_id"
      t.string   "bookmarkable_type"
      t.string   "bookmarkable_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "brain_busters", :id => false, :force => true do |t|
      t.string "uuid",     :limit => 36
      t.string "question"
      t.string "answer"
    end

    create_table "caching_stats", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "key"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "caching_stats", ["key"], :name => "index_caching_stats_on_key"
    add_index "caching_stats", ["uuid"], :name => "index_caching_stats_on_uuid", :unique => true

    create_table "commendations", :id => false, :force => true do |t|
      t.string   "uuid",             :limit => 36
      t.string   "receiver_email"
      t.string   "sender_email"
      t.string   "sender_name"
      t.string   "receiver_name"
      t.string   "commendable_id"
      t.string   "commendable_type"
      t.text     "message"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "comments", :id => false, :force => true do |t|
      t.string   "uuid",             :limit => 36
      t.string   "author_id"
      t.string   "author_type"
      t.string   "commentable_id"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "parent_id"
      t.string   "name"
      t.string   "email"
      t.string   "website"
      t.string   "state"
      t.string   "ip"
      t.datetime "deleted_at"
      t.string   "commentable_type"
    end

    create_table "containers", :id => false, :force => true do |t|
      t.string   "uuid",               :limit => 36
      t.string   "shortcut"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "type"
      t.string   "sub_container_id"
      t.string   "sub_container_type"
      t.integer  "positions"
    end

    create_table "content_elements", :id => false, :force => true do |t|
      t.string   "uuid",           :limit => 36
      t.string   "layout"
      t.integer  "position"
      t.string   "container_id"
      t.string   "container_type"
      t.string   "element_id"
      t.string   "element_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "content_landing_page_tabs", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "name"
      t.string   "element_id"
      t.string   "element_type"
      t.boolean  "latest",                     :default => false
      t.date     "hide_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "content_latest_elements", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "element_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "content_texts", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "title"
      t.text     "bodytext"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "type"
    end

    create_table "content_top_elements", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "element_id"
      t.string   "element_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
    end

    create_table "content_welcome_page_teaser_images", :id => false, :force => true do |t|
      t.string   "uuid",                           :limit => 36
      t.string   "content_type"
      t.integer  "size"
      t.string   "filename"
      t.integer  "height"
      t.integer  "width"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.string   "content_welcome_page_teaser_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "content_welcome_page_teasers", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "name"
      t.string   "title"
      t.string   "element_id"
      t.string   "element_type"
      t.text     "bodytext"
      t.boolean  "show_text"
      t.boolean  "show_element"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "corporate_forms", :id => false, :force => true do |t|
      t.string   "uuid",        :limit => 36
      t.string   "name"
      t.string   "shortname"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "helpedia_id"
      t.string   "elargio_id"
      t.boolean  "public",                    :default => false
    end

    add_index "corporate_forms", ["uuid"], :name => "index_corporate_forms_on_uuid", :unique => true

    create_table "countries", :id => false, :force => true do |t|
      t.string   "uuid",                   :limit => 36
      t.string   "code",                   :limit => 2
      t.string   "en"
      t.string   "date_format"
      t.string   "currency_format"
      t.string   "currency_code",          :limit => 3
      t.string   "thousands_sep",          :limit => 2
      t.string   "decimal_sep",            :limit => 2
      t.string   "currency_decimal_sep",   :limit => 2
      t.string   "number_grouping_scheme"
      t.string   "de"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "helpedia_id"
    end

    add_index "countries", ["uuid"], :name => "index_countries_on_uuid", :unique => true

    create_table "countries_organisations", :id => false, :force => true do |t|
      t.string "country_id"
      t.string "organisation_id"
    end

    add_index "countries_organisations", ["country_id", "organisation_id"], :name => "index_countries_organisations_on_country_id_and_organisation_id"

    create_table "daily_ids", :id => false, :force => true do |t|
      t.integer "daily_id",   :default => 1
      t.string  "uuid"
      t.date    "created_on"
    end

    create_table "days_with_events", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "event_id"
      t.datetime "day"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "document_attachments", :id => false, :force => true do |t|
      t.string   "uuid",            :limit => 36
      t.string   "attachable_type"
      t.string   "attachable_id"
      t.string   "type"
      t.string   "document_id"
      t.string   "year"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "document_attachments", ["attachable_type", "attachable_id"], :name => "index_document_attachments_on_attachable_type_and_attachable_id"
    add_index "document_attachments", ["document_id"], :name => "index_document_attachments_on_document_id"
    add_index "document_attachments", ["uuid"], :name => "index_document_attachments_on_uuid", :unique => true

    create_table "documents", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "size"
      t.string   "content_type"
      t.string   "filename"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "owner_id"
      t.string   "owner_type"
      t.string   "helpedia_id"
    end

    add_index "documents", ["owner_id", "owner_type"], :name => "index_documents_on_owner_id_and_owner_type"
    add_index "documents", ["uuid"], :name => "index_documents_on_uuid", :unique => true

    create_table "event_categories", :id => false, :force => true do |t|
      t.string   "uuid",        :limit => 36
      t.string   "name"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "event_categories", ["uuid"], :name => "index_event_categories_on_uuid", :unique => true

    create_table "event_category_images", :id => false, :force => true do |t|
      t.string   "uuid",              :limit => 36
      t.string   "filename"
      t.string   "content_type"
      t.string   "size"
      t.string   "width"
      t.string   "height"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.string   "event_category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "events", :id => false, :force => true do |t|
      t.string   "uuid",              :limit => 36
      t.string   "title"
      t.string   "permalink"
      t.string   "website"
      t.text     "description"
      t.string   "originator_id"
      t.string   "originator_type"
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "admin_comment"
      t.string   "event_type"
      t.datetime "deleted_at"
      t.string   "state"
      t.string   "location_id"
      t.string   "organisation_id"
      t.string   "organisation_name"
      t.string   "commentable",                     :default => "1"
    end

    add_index "events", ["originator_id"], :name => "index_events_on_originator_id"
    add_index "events", ["originator_type"], :name => "index_events_on_originator_type"
    add_index "events", ["uuid"], :name => "index_events_on_uuid", :unique => true

    create_table "external_profile_memberships", :id => false, :force => true do |t|
      t.string   "uuid",                :limit => 36
      t.string   "user_id"
      t.string   "external_profile_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "url"
      t.string   "description"
    end

    add_index "external_profile_memberships", ["uuid"], :name => "index_external_profile_memberships_on_uuid", :unique => true

    create_table "external_profiles", :id => false, :force => true do |t|
      t.string   "uuid",        :limit => 36
      t.string   "title"
      t.text     "description"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "external_profiles", ["uuid"], :name => "index_external_profiles_on_uuid", :unique => true

    create_table "feed_event_streams", :id => false, :force => true do |t|
      t.string   "uuid",            :limit => 36
      t.string   "feed_event_id"
      t.string   "streamable_id"
      t.string   "streamable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "feed_events", :id => false, :force => true do |t|
      t.string   "uuid",           :limit => 36
      t.boolean  "is_public",                    :default => false, :null => false
      t.string   "trigger_id"
      t.string   "trigger_type"
      t.string   "operator_id"
      t.string   "operator_type"
      t.string   "type"
      t.text     "changes"
      t.text     "cache"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "concerned_type"
      t.string   "concerned_id"
      t.string   "lng"
      t.string   "lat"
    end

    create_table "friendships", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "user_id"
      t.string   "user_type"
      t.string   "friend_id"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "image_attachments", :id => false, :force => true do |t|
      t.string   "uuid",               :limit => 36
      t.string   "attachable_type"
      t.string   "attachable_id"
      t.string   "image_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "deleted_at"
      t.string   "width"
      t.string   "height"
      t.string   "horizontical_align"
    end

    add_index "image_attachments", ["attachable_type", "attachable_id"], :name => "index_image_attachments_on_attachable_type_and_attachable_id"
    add_index "image_attachments", ["image_id"], :name => "index_image_attachments_on_image_id"
    add_index "image_attachments", ["uuid"], :name => "index_image_attachments_on_uuid", :unique => true

    create_table "images", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "filename"
      t.string   "content_type"
      t.string   "size"
      t.string   "width"
      t.string   "height"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.string   "owner_id"
      t.string   "owner_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "deleted_at"
    end

    add_index "images", ["owner_id", "owner_type"], :name => "index_images_on_owner_id_and_owner_type"
    add_index "images", ["parent_id"], :name => "index_images_on_parent_id"
    add_index "images", ["uuid"], :name => "index_images_on_uuid", :unique => true

    create_table "location_categories", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "name"
      t.string   "parent_id"
      t.string   "permalink"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "location_category_memberships", :id => false, :force => true do |t|
      t.string "uuid",                 :limit => 36
      t.string "location_id",          :limit => 36
      t.string "location_category_id", :limit => 36
    end

    create_table "location_memberships", :id => false, :force => true do |t|
      t.string   "uuid",        :limit => 36
      t.string   "location_id"
      t.string   "member_id"
      t.string   "member_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "locations", :id => false, :force => true do |t|
      t.string   "uuid",           :limit => 36
      t.string   "name"
      t.text     "description"
      t.string   "permalink"
      t.string   "owner_id"
      t.string   "owner_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "phone"
      t.string   "fax"
      t.string   "website"
      t.string   "email"
      t.string   "contact_person"
      t.datetime "deleted_at"
      t.string   "state"
      t.text     "admin_comment"
      t.string   "commentable",                  :default => "1"
    end

    create_table "messages", :id => false, :force => true do |t|
      t.string   "uuid",                 :limit => 36
      t.string   "recipient_id",                                          :null => false
      t.string   "sender_id",                                             :null => false
      t.string   "reply_to_id"
      t.string   "subject"
      t.text     "body"
      t.datetime "sent_at"
      t.datetime "read_at"
      t.datetime "replied_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "helpedia_id"
      t.string   "sender_type"
      t.string   "recipient_type"
      t.datetime "recipient_deleted_at"
      t.datetime "sender_deleted_at"
      t.string   "conversation_id"
      t.boolean  "system_message",                     :default => false
    end

    create_table "news", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "title"
      t.string   "url"
      t.string   "subtitle"
      t.text     "teaser"
      t.text     "message"
      t.integer  "elargio_id"
      t.string   "created_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "permalink"
      t.boolean  "press_news",                 :default => false
      t.string   "publisher"
      t.date     "published_on"
    end

    create_table "news_categories", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "title"
      t.integer  "elargio_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "permalink"
    end

    create_table "news_memberships", :id => false, :force => true do |t|
      t.string   "uuid",             :limit => 36
      t.string   "news_id"
      t.string   "news_category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "newsletter_subscribers", :id => false, :force => true do |t|
      t.string   "uuid",              :limit => 36
      t.boolean  "for_users",                       :default => false
      t.boolean  "for_organisations",               :default => false
      t.string   "email"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "name"
      t.string   "confirmation_code"
      t.string   "state"
    end

    create_table "organisation_certificate_images", :id => false, :force => true do |t|
      t.string   "uuid",                        :limit => 36
      t.string   "filename"
      t.string   "content_type"
      t.string   "size"
      t.string   "width"
      t.string   "height"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.string   "organisation_certificate_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "organisation_certificate_memberships", :id => false, :force => true do |t|
      t.string   "uuid",                        :limit => 36
      t.string   "organisation_id"
      t.string   "organisation_certificate_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "organisation_certificates", :id => false, :force => true do |t|
      t.string   "uuid",         :limit => 36
      t.string   "title"
      t.text     "description"
      t.string   "filename"
      t.string   "content_type"
      t.string   "size"
      t.string   "width"
      t.string   "height"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "elargio_id"
    end

    create_table "organisation_memberships", :id => false, :force => true do |t|
      t.string   "uuid",           :limit => 36
      t.string   "association_id"
      t.string   "member_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "organisations", :id => false, :force => true do |t|
      t.string   "uuid",                         :limit => 36
      t.string   "short_name",                   :limit => 40
      t.string   "permalink",                    :limit => 40
      t.string   "name",                         :limit => 100, :default => ""
      t.string   "email",                        :limit => 100
      t.string   "crypted_password",             :limit => 40
      t.string   "salt",                         :limit => 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remember_token",               :limit => 40
      t.datetime "remember_token_expires_at"
      t.string   "activation_code",              :limit => 40
      t.datetime "activated_at"
      t.string   "state",                                       :default => "passive"
      t.datetime "deleted_at"
      t.string   "corporate_form_id"
      t.datetime "logged_in_at"
      t.string   "website"
      t.string   "contact_name"
      t.string   "contact_email"
      t.string   "contact_phone"
      t.text     "description"
      t.string   "phone_number"
      t.string   "fax_number"
      t.string   "helpedia_contact_name"
      t.string   "helpedia_contact_email"
      t.string   "helpedia_contact_phone"
      t.string   "legal_entity_id"
      t.string   "password_reset_code"
      t.string   "main_category_id"
      t.string   "activated_by"
      t.date     "notice_of_excemption_ends_on"
      t.boolean  "notice_of_excemption",                        :default => false
      t.string   "username"
      t.text     "admin_comment"
      t.boolean  "subscribed_newsletter",                       :default => false
      t.string   "api_key"
      t.string   "hostname"
      t.datetime "first_logged_in_at"
    end

    add_index "organisations", ["corporate_form_id"], :name => "index_organisations_on_corporate_form_id"
    add_index "organisations", ["legal_entity_id"], :name => "index_organisations_on_legal_entity_id"
    add_index "organisations", ["main_category_id"], :name => "index_organisations_on_main_category_id"
    add_index "organisations", ["permalink"], :name => "index_organisations_on_permalink"
    add_index "organisations", ["uuid"], :name => "index_organisations_on_uuid", :unique => true

    create_table "page_views", :id => false, :force => true do |t|
      t.string   "uuid",          :limit => 36
      t.string   "viewable_id"
      t.string   "viewable_type"
      t.string   "request_url",   :limit => 200
      t.string   "session",       :limit => 32
      t.string   "ip_address",    :limit => 16
      t.string   "referer",       :limit => 200
      t.string   "user_agent",    :limit => 200
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "pages", :id => false, :force => true do |t|
      t.string   "uuid",           :limit => 36
      t.string   "name"
      t.string   "permalink"
      t.text     "content"
      t.text     "border_content"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "roles", :id => false, :force => true do |t|
      t.string "uuid",  :limit => 36
      t.string "name"
      t.string "title"
    end

    create_table "roles_users", :id => false, :force => true do |t|
      t.string "role_id"
      t.string "user_id"
    end

    add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
    add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

    create_table "sessions", :id => false, :force => true do |t|
      t.string   "uuid"
      t.string   "session_id", :null => false
      t.text     "data"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"
    add_index "sessions", ["uuid"], :name => "index_sessions_on_uuid", :unique => true

    create_table "simple_captcha_data", :id => false, :force => true do |t|
      t.string   "uuid",       :limit => 36
      t.string   "key",        :limit => 40
      t.string   "value",      :limit => 6
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "social_categories", :id => false, :force => true do |t|
      t.string "uuid",        :limit => 36
      t.string "title"
      t.text   "description"
      t.string "helpedia_id"
      t.string "elargio_id"
      t.string "permalink"
    end

    add_index "social_categories", ["uuid"], :name => "index_social_categories_on_uuid", :unique => true

    create_table "social_category_images", :id => false, :force => true do |t|
      t.string   "uuid",               :limit => 36
      t.string   "filename"
      t.string   "content_type"
      t.string   "size"
      t.string   "width"
      t.string   "height"
      t.string   "parent_id"
      t.string   "thumbnail"
      t.string   "social_category_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "social_category_memberships", :id => false, :force => true do |t|
      t.string   "uuid",               :limit => 36
      t.string   "social_category_id"
      t.string   "member_id"
      t.string   "member_type"
      t.boolean  "main",                             :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "social_category_memberships", ["member_id"], :name => "index_social_category_memberships_on_member_id"
    add_index "social_category_memberships", ["member_type"], :name => "index_social_category_memberships_on_member_type"
    add_index "social_category_memberships", ["social_category_id"], :name => "index_social_category_memberships_on_social_category_id"
    add_index "social_category_memberships", ["uuid"], :name => "index_social_category_memberships_on_uuid", :unique => true

    create_table "taggings", :id => false, :force => true do |t|
      t.string   "uuid",          :limit => 36
      t.string   "tag_id"
      t.string   "taggable_id"
      t.string   "tagger_id"
      t.string   "tagger_type"
      t.string   "taggable_type"
      t.string   "context"
      t.datetime "created_at"
    end

    add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

    create_table "tags", :id => false, :force => true do |t|
      t.string "uuid", :limit => 36
      t.string "name"
    end

    create_table "temporary_donations", :id => false, :force => true do |t|
      t.string   "first_name"
      t.string   "last_name"
      t.string   "street"
      t.string   "zip"
      t.string   "city"
      t.string   "email"
      t.string   "ip"
      t.string   "username"
      t.integer  "amount"
      t.text     "message"
      t.boolean  "successfull",                           :default => false
      t.string   "transaction_id"
      t.string   "custom_amount"
      t.date     "birthday"
      t.integer  "real_amount"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "paytype"
      t.string   "c_pay_id"
      t.string   "c_status"
      t.string   "c_error_code"
      t.string   "c_xid"
      t.string   "c_description"
      t.string   "reference_number"
      t.string   "show"
      t.string   "donation_bank"
      t.string   "donation_account_number"
      t.string   "donation_bank_number"
      t.string   "donation_account_owner"
      t.string   "country"
      t.string   "uuid",                    :limit => 36
      t.string   "activity_id"
      t.string   "user_id"
      t.string   "organisation_id"
    end

    create_table "users", :id => false, :force => true do |t|
      t.string   "uuid",                         :limit => 36
      t.string   "permalink",                    :limit => 40
      t.string   "last_name",                    :limit => 100, :default => ""
      t.string   "first_name",                   :limit => 100, :default => ""
      t.string   "company_name",                 :limit => 100, :default => ""
      t.string   "email",                        :limit => 100
      t.string   "crypted_password",             :limit => 40
      t.string   "salt",                         :limit => 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "remember_token",               :limit => 40
      t.datetime "remember_token_expires_at"
      t.string   "activation_code"
      t.datetime "activated_at"
      t.string   "state",                                       :default => "passive"
      t.datetime "deleted_at"
      t.date     "birthday"
      t.datetime "logged_in_at"
      t.text     "about_me"
      t.string   "title"
      t.string   "gender"
      t.string   "phone"
      t.integer  "elargio_id"
      t.integer  "helpedia_id"
      t.string   "visibility"
      t.boolean  "receive_message_notification"
      t.string   "helpedia_type"
      t.string   "password_reset_code"
      t.string   "helpedia_profile_id"
      t.string   "elargio_user_profile_id"
      t.string   "username"
      t.text     "admin_comment"
      t.boolean  "subscribed_newsletter",                       :default => false
      t.integer  "fairdo_id"
      t.text     "changed_my_life"
      t.text     "inspires_me"
      t.text     "my_contribution"
      t.text     "dislike"
      t.boolean  "accept_taz_agb"
      t.string   "fairdo_username"
      t.datetime "first_logged_in_at"
    end

    add_index "users", ["permalink"], :name => "index_users_on_permalink", :unique => true
    add_index "users", ["uuid"], :name => "index_users_on_uuid", :unique => true

  end
end
