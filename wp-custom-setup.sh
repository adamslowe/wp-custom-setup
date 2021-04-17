#!/bin/bash
# Blueprint Date: 4/17/2021 - Sanitized version
##      ToDo:
##      -- fix for seopress on nginx
##      -- nginx caching settings 
##      -- add clean talk
##      -- add wp feedback
##      -- add loginpress pro
##      -- add dynamic content for elementor
##      -- add essential addons for elementor
##      -- add happy files pro
##      -- add fluent forms
##      -- add kadance theme & blocks
##      -- add admin menu editor
##      -- add blocksy
##      -- add stackable
##      -- add admin menu editor and settings

function initialize_variables(){
    site_name=$(wp option get blogname)
    site_description=$(wp option get blogdescription)
    admin_email_address=$(wp option get admin_email)
    dl_seopress_pro=
    dl_ithemes_security_pro=
    dl_updraft_plus=
    dl_wp_rocket=
    dl_astra_child=
    dl_astra_addon=
    dl_generatepress_pro=
    dl_elementor_pro=
    dl_elementor_coming_soon=
    dl_elementor_attribution=
    dl_elementor_style=
    dl_wpfeedback="
    dl_style_kit=
    dl_oxygen_base=
    dl_oxygen_gutenberg=
    dl_hydrogen=
    dl_oxy_toolbox=
    dl_oxy_extras=
    dl_advanced_scripts=
    dl_advanced_custom_fields=
    dl_gravity_forms=
    dl_happy_files=
    apikey_sendgrid=
    apikey_cloudflare=
    cloudflare_email=
    apikey_shortpixel=
    apikey_wasabi_access=
    apikey_wasabi_secret=
}

########################################
###### Default WordPress Settings ######
########################################

function wp_settings_general(){ echo "Setting general WordPress settings"
    wp option update blogname "$site_name"
    wp option update blogdescription "$site_description"
    wp option update admin_email $admin_email_address
    wp option update timezone_string "America/New_York"
    wp option update start_of_week 0
}
function wp_settings_system(){ echo "Setting WordPress system settings"
    wp config set AUTOMATIC_UPDATER_DISABLED true
    wp config shuffle-salts
}
function wp_settings_pages_posts(){ echo "Setting Page & Post Settings"
    wp post delete $(wp post list --post_type='post' --format=ids) --force
    wp post delete $(wp post list --post_type='page' --name=sample-page --format=ids) --force
    wp post create --post_type=page --post_status=publish --post_title="Home" 
    wp post create --post_type=page --post_status=publish --post_title="Blog"
    wp term update category 1 --name=General --slug=general
}
function wp_settings_reading(){ echo "Setting reading settings"
    wp option update show_on_front page
    wp option update page_on_front $(wp post list --post_type='page' --name=home --format=ids)
    wp option update page_for_posts $(wp post list --post_type='page' --name=blog --format=ids)
    wp option update rss_use_excerpt 1
    wp option update blog_public 0
}
function wp_settings_discussion(){ echo "Setting discussion settings"
    wp option update default_comment_status closed
    wp option update comment_registration 1
    wp option update comment_moderation 1
    wp option update show_avatars 0
}
function wp_settings_media(){ echo "Setting media settings"
    wp option update thumbnail_size_w 150
    wp option update thumbnail_size_h 150
    wp option update medium_size_w 500
    wp option update medium_size_h 9999
    wp option update large_size_w 1800
    wp option update large_size_h 9999
}
function wp_settings_permalinks(){ echo "Setting permalink settings"
    wp rewrite structure '/%postname%/' 
    wp rewrite flush
}
function wp_themes_remove_unneeded(){ echo "Removing unneeded themes"
    wp theme delete twentysixteen twentyseventeen twentynineteen twentytwenty
}
function wp_plugins_remove_unneeded(){ echo "Removing unneeded plugins"
    wp plugin deactivate akismet hello breeze; wp plugin delete akismet hello breeze
    wp plugin update --all && wp theme update --all
}
function wp_user_admin_defaults(){ echo "Setting default admin and developer user settings"
    wp db query 'UPDATE wp_users SET user_login="admin_'$domain_identifier'" WHERE ID=1'
    wp user update 1 --first_name="Website" --last_name="Administrator" --nickname="Website Administrator" --display_name="Website Administrator" --user_url="https://www.peakperformancedigital.com/" --skip-email
    wp user create devteam_$domain_identifier [[replaceme]] --role=administrator --display_name="Website Developer" --nickname="Website Developer" --first_name="Website" --last_name="Developer"
}
function wp_roles_create_defaults(){ echo "Creating default user roles"
    wp role create websiteowner "Website Owner" --clone=editor
    wp role create seospecialist "SEO Specialist" --clone=editor 
}

#######################################
###### Non-Default Settings Here ######
#######################################
function make_default_pages() {
    wp post create --post_type=page --post_status=publish --post_title="Terms of Use"
    wp post create --post_type=page --post_status=publish --post_title="Services"; wp post create --post_type=page --post_status=publish --post_title="About"; wp post create --post_type=page --post_status=publish --post_title="Contact"   
    wp menu create "Primary Menu"
    wp menu item add-post primary-menu $(wp post list --post_type='page' --name=services  --format=ids)
    wp menu item add-post primary-menu $(wp post list --post_type='page' --name=about  --format=ids)
    wp menu item add-post primary-menu $(wp post list --post_type='page' --name=blog  --format=ids)
    wp menu item add-post primary-menu $(wp post list --post_type='page' --name=contact  --format=ids)
    wp menu location assign "Primary Menu" primary
}

############################################
###### Base Application Settings Here ######
############################################
function install_config_fluentsmtp(){ echo "Installing and configuring Fluent SMTP"
    wp plugin install fluent-smtp --activate
    wp option update fluentmail-settings --format=json '{"mappings":{"[[replaceme]]":"2a001e2752255da416d3467ed4893ecb"},"connections":{"2a001e2752255da416d3467ed4893ecb":{"title":"SendGrid","provider_settings":{"sender_name":"'"$site_name"'","sender_email":"[[replaceme]]","force_from_name":"no","force_from_email":"no","api_key":"","key_store":"db","provider":"sendgrid"}}},"misc":{"log_emails":"yes","log_saved_interval_days":"14","disable_fluentcrm_logs":"no","default_connection":"2a001e2752255da416d3467ed4893ecb"}}'
}
function install_config_updraft(){ echo "Installing and configuring Updraft Plus"
    wp plugin install $dl_updraft_plus --activate
    wp option update updraftplus_tour_cancelled_on backup_now
    wp option update updraft_interval "daily"
    wp option update updraft_startday_files 0
    wp option update updraft_starttime_files "01:00"
    wp option update updraft_retain 30
    wp option update updraft_interval_increments "none"
    wp option update updraft_retain_extrarules --format=json '{"files":[null,{"after-howmany":"12","after-period":"604800","every-howmany":"1","every-period":"604800"}],"db":[null,{"after-howmany":"12","after-period":"604800","every-howmany":"1","every-period":"604800"}]}'
    wp option update updraft_interval_database "daily"
    wp option update updraft_startday_db 0
    wp option update updraft_starttime_db "01:00"
    wp option update updraft_retain_db 30
    wp option update updraft_service --format=json '["s3generic"]'
    wp option update updraft_s3generic --format=json '{"version":"1","settings":{"s-3dbdc8c7739fea32a50dcfa027648772":{"instance_enabled":"1","instance_label":"","accesskey":"'$apikey_wasabi_access'","secretkey":"'$apikey_wasabi_secret'","path":"ppd-sites/'$site_fqdn'","endpoint":"s3.wasabisys.com"}}}'
    wp option update updraft_email $backup_email_address
    wp option update updraft_report_warningsonly 0
    wp option update updraft_report_wholebackup 0
    wp option update updraft_autobackup_default 0
    if [ $server_type=="OpenLiteSpeed" ]; then
        echo "">> .htaccess
        echo "### UpdraftPlus OLS fix start ###" >> .htaccess
        echo "RewriteRule .* - [E=noabort:1]" >> .htaccess
        echo "### UpdraftPlus OLS fix end ###" >> .htaccess
        echo "">> .htaccess
    fi
}
function install_config_seopress(){ echo "Installing and configuring SEOpress"
    wp plugin install wp-seopress $dl_seopress_pro --activate
    wp option update seopress_pro_license_key ""
}
function install_config_ithemessecurity(){ echo "Installing and configuring iThemes Security Pro"
    wp plugin install $dl_ithemes_security_pro --activate
    wp ithemes-licensing activate ithemes-security-pro --ithemes-user="" --ithemes-pass=''
    wp option update itsec_active_modules --format=json '{"ban-users":true,"backup":true,"brute-force":true,"network-brute-force":true,"wordpress-tweaks":true,"magic-links":true,"malware-scheduling":true,"two-factor":false,"user-logging":true,"version-management":true,"system-tweaks":true,"ssl":true,"dashboard":true,"recaptcha":false,"404-detection":true}'        
    wp option update --format=json itsec_cron '{"single":{"preload-ithemes-hashes":[],"remote-messages":[],"preload-plugin-hashes":[],"confirm-valid-wporg-plugin":[]},"recurring":{"purge-log-entries":{"data":[]},"clear-locks":{"data":[]},"health-check":{"data":[]},"clear-tokens":{"data":[]},"flush-files":{"data":[]},"geolocation-refresh":{"data":[]},"malware-scan":{"data":[]}}}'
    wp option update --format=json itsec_dismissed_notices '["network-brute-force-promo","release-rcp"]'
    wp option update --format=json itsec_remote_messages '{"response":{"ttl":43200,"messages":[],"features":{"site_scanner":{"rate":10,"disabled":true,"requirements":[]},"site_scanner_p1":{"rate":90,"disabled":false,"requirements":[]}},"actions":[]},"ttl":43200,"requested":1615754168}'
    wp option update --format=json itsec-storage '{"global":{"write_files":true,"lockout_message":"error","user_lockout_message":"You have been locked out due to too many invalid login attempts.","community_lockout_message":"Your IP address has been flagged as a threat by the iThemes Security network.","blacklist":true,"blacklist_count":3,"blacklist_period":7,"lockout_period":15,"lockout_white_list":[],"log_type":"database","log_rotation":60,"file_log_rotation":180,"proxy":"automatic","proxy_header":"HTTP_X_FORWARDED_FOR","hide_admin_bar":true,"show_error_codes":false,"enable_grade_report":false,"allow_tracking":false,"manage_group":[],"infinitewp_compatibility":false,"did_upgrade":false,"log_info":"","show_security_check":false,"build":4122,"activation_timestamp":1615667311,"lock_file":false,"cron_status":1,"use_cron":true,"cron_test_time":1615763314,"server_ips":[],"initial_build":4122,"feature_flags":[],"licensed_hostname_prompt":false},"notification-center":{"from_email":"[[replaceme]]","default_recipients":{"user_list":["1"]},"notifications":{"automatic-updates-debug":{"enabled":true,"recipient_type":"default","user_list":["role:administrator"]},"backup":{"subject":null,"email_list":["[[replaceme]]"]},"inactive-users":{"enabled":true,"subject":null,"schedule":"daily","recipient_type":"default","user_list":["role:administrator"]},"magic-link-login-page":{"subject":null,"message":"Hi {{ $display_name }},\r\n\r\nFor security purposes, please click the button below to login.\r\n\r\nRegards,\r\nAll at {{ $site_title }}"},"digest":{"subject":null,"schedule":"daily","recipient_type":"default","user_list":["role:administrator"],"enabled":false},"import-export":{"subject":null,"message":null},"lockout":{"enabled":true,"subject":null,"recipient_type":"default","user_list":["role:administrator"]},"malware-scheduling":{"enabled":true,"recipient_type":"default","user_list":["role:administrator"]},"two-factor-email":{"subject":null,"message":"Hi {{ $display_name }},\r\n\r\nClick the button to continue or manually enter the authentication code below to finish logging in."},"two-factor-confirm-email":{"enabled":true,"subject":null,"message":"Hi {{ $display_name }},\r\n\r\nClick the button to continue or manually enter the authentication code below to finish setting up Two-Factor."},"two-factor-reminder":{"subject":null,"message":"Hi {{ $display_name }},\r\n\t\t\t\r\n{{ $requester_display_name }} from {{ $site_title }} has asked that you set up Two Factor Authentication."}},"last_sent":{"digest":1615753714,"inactive-users":1615753714},"data":{"digest":[],"inactive-users":[]},"resend_at":[],"admin_emails":[],"last_mail_error":""},"version-management":{"wordpress_automatic_updates":true,"plugin_automatic_updates":"none","theme_automatic_updates":"none","packages":[],"strengthen_when_outdated":false,"scan_for_old_wordpress_sites":false,"update_details":[],"is_software_outdated":false,"old_site_details":[],"system-tweaks":{"directory_browsing":true,"long_url_strings":true,"uploads_php":true,"plugins_php":true,"themes_php":true,"protect_files":false,"request_methods":false,"suspicious_query_strings":false,"non_english_characters":false,"write_permissions":false},"ssl":{"require_ssl":"enabled","frontend":0,"admin":false},"wordpress-tweaks":{"wlwmanifest_header":true,"edituri_header":true,"comment_spam":true,"file_editor":true,"disable_xmlrpc":0,"allow_xmlrpc_multiauth":false,"rest_api":"default-access","disable_unused_author_pages":true,"valid_user_login_type":"both","patch_thumb_file_traversal":true,"login_errors":false,"force_unique_nicename":false,"block_tabnapping":false},"404-detection":{"check_period":5,"error_threshold":20,"white_list":["\/favicon.ico","\/robots.txt","\/apple-touch-icon.png","\/apple-touch-icon-precomposed.png","\/wp-content\/cache","\/browserconfig.xml","\/crossdomain.xml","\/labels.rdf","\/trafficbasedsspsitemap.xml"],"types":[".jpg",".jpeg",".png",".gif",".css"]}}}'
}
function install_config_shortpixel(){ echo "Installing and configuring shortpixel"
    wp plugin install shortpixel-image-optimiser enable-media-replace
    wp option update emr_news 1
    wp option update wp-short-pixel-apiKey $apikey_shortpixel
    wp option update wp-short-pixel-resize-images 1
    wp option update wp-short-pixel-resize-width 2000
    wp option update wp-short-pixel-resize-height 9999
    wp option update wp-short-pixel-png2jpg 1
    wp option update wp-short-create-webp 1
    wp option update wp-short-pixel-create-webp-markup 2
    wp option update wp-short-pixel-cloudflareAPIEmail $cloudflare_email
    wp option update wp-short-pixel-cloudflareAuthKey $apikey_cloudflare
    wp option update wp-short-pixel-activation-notice 1
}
function install_config_wprocket(){ echo "Installing and configuring wp Rocket" 
    wp plugin install $dl_wp_rocket --activate
    wp option update rocket_analytics_notice_displayed 1
    wp option update wp_rocket_settings --format=json '{"cache_mobile":1,"do_caching_mobile_files":1,"cache_logged_user":0,"purge_cron_interval":10,"purge_cron_unit":"DAY_IN_SECONDS","minify_html":1,"minify_google_fonts":1,"remove_query_strings":1,"minify_css":1,"exclude_css":[],"async_css":1,"critical_css":"","minify_js":1,"exclude_inline_js":[],"exclude_js":[],"defer_all_js":1,"defer_all_js_safe":1,"lazyload":1,"lazyload_iframes":1,"lazyload_youtube":1,"emoji":1,"embeds":1,"manual_preload":1,"sitemap_preload":1,"seopress_xml_sitemap":"1","sitemaps":[],"dns_prefetch":["\/\/maps.googleapis.com","\/\/maps.gstatic.com","\/\/fonts.googleapis.com","\/\/fonts.gstatic.com","\/\/ajax.googleapis.com","\/\/apis.google.com","\/\/google-analytics.com","\/\/www.google-analytics.com","\/\/ssl.google-analytics.com","\/\/youtube.com","\/\/api.pinterest.com","\/\/cdnjs.cloudflare.com","\/\/pixel.wp.com","\/\/connect.facebook.net","\/\/platform.twitter.com","\/\/syndication.twitter.com","\/\/platform.instagram.com","\/\/disqus.com","\/\/sitename.disqus.com","\/\/s7.addthis.com","\/\/platform.linkedin.com","\/\/w.sharethis.com","\/\/s0.wp.com","\/\/s.gravatar.com","\/\/stats.wp.com","\/\/diffuser-cdn.app-us1.com"],"cache_reject_uri":[],"cache_reject_cookies":[],"cache_reject_ua":[],"cache_purge_pages":[],"cache_query_strings":[],"automatic_cleanup_frequency":"","cdn_cnames":[],"cdn_zone":[],"cdn_reject_files":[],"heartbeat_admin_behavior":"reduce_periodicity","heartbeat_editor_behavior":"reduce_periodicity","heartbeat_site_behavior":"reduce_periodicity","google_analytics_cache":"1","facebook_pixel_cache":"1","varnish_auto_purge":1,"cloudflare_api_key":"'$apikey_cloudflare'","cloudflare_email":"'$cloudflare_email'","cloudflare_zone_id":"","cloudflare_auto_settings":1,"sucury_waf_api_key":"","version":"3.4.1.2","cloudflare_old_settings":"","sitemap_preload_url_crawl":"500000","cache_ssl":1,"do_beta":0,"minify_concatenate_css":0,"minify_concatenate_js":0,"database_revisions":0,"database_auto_drafts":0,"database_trashed_posts":0,"database_spam_comments":0,"database_trashed_comments":0,"database_expired_transients":0,"database_all_transients":0,"database_optimize_tables":0,"schedule_automatic_cleanup":0,"do_cloudflare":0,"cloudflare_devmode":0,"cloudflare_protocol_rewrite":0,"sucury_waf_cache_sync":0,"control_heartbeat":0,"cdn":0}'
}
function install_config_litespeedcache(){ echo "Installing and configuring LiteSpeed Cache"
    wp plugin install litespeed-cache --activate
    wp option update litespeed.conf.cache 0
    wp option update litespeed.conf.cache-browser 1
    wp option update litespeed.conf.cdn-cloudflare 1
    wp option update litespeed.conf.cdn-cloudflare_email $cloudflare_email
    wp option update litespeed.conf.cdn-cloudflare_key $apikey_cloudflare
    wp option update litespeed.conf.cdn-cloudflare_name peakperformance.dev
    wp option update litespeed.conf.cdn-cloudflare_zone ""
    wp option update litespeed.conf.optm-css_min 1
    wp option update litespeed.conf.optm-css_comb 0
    wp option update litespeed.conf.optm-css_comb_ext_inl 0
    wp option update litespeed.conf.optm-css_http2 1
    wp option update litespeed.conf.optm-ccss_async 1
    wp option update litespeed.conf.optm-css_async 1
    wp option update litespeed.conf.optm-ccss_gen 1
    wp option update litespeed.conf.optm-css_async_inline 1
    wp option update litespeed.conf.optm-ccss_con 0
    wp option update litespeed.conf.optm-css_font_display 2
    wp option update litespeed.conf.optm-js_min 1
    wp option update litespeed.conf.optm-js_comb 0
    wp option update litespeed.conf.optm-js_comb_ext_inl 0
    wp option update litespeed.conf.optm-js_http2 1
    wp option update litespeed.conf.optm-js_defer 1
    wp option update litespeed.conf.optm-js_inline_defer 2
    wp option update litespeed.conf.optm-html_min 1
    wp option update litespeed.conf.optm-dns_prefetch_ctrl 1
    wp option update litespeed.conf.optm-ggfonts_async 1
    wp option update litespeed.conf.optm-emoji_rm 1
    wp option update litespeed.conf.optm-noscript_rm 1
    wp option update litespeed.conf.media-lazy 1
    wp option update litespeed.conf.media-placeholder_resp 1
    wp option update litespeed.conf.media-placeholder_resp_async 1
    wp option update litespeed.conf.media-iframe_lazy 1
    wp option update litespeed.conf.media-lazyjs_inline 1
    wp option update litespeed.conf.discuss-avatar_cache 1
    wp option update litespeed.conf.discuss-avatar_cron 1
    wp option update litespeed.conf.optm-localize 0
}
function install_mainwp(){
    wp plugin install mainwp-child
}

################################################
###### Non-Base Application Settings Here ######
################################################
function install_config_astra(){ echo "Installing and Configuring Astra"
    wp theme install astra 
    wp theme install $dl_astra_child --activate
    wp plugin install $dl_astra_addon --activate
    wp brainstormforce license activate astra-addon ""
    wp option update _astra_file_generation enable
    wp option update _astra_ext_enabled_extensions --format=json '{"advanced-hooks":"advanced-hooks","blog-pro":"blog-pro","colors-and-background":"colors-and-background","advanced-footer":"","mobile-header":"","header-sections":"","lifterlms":"","learndash":"","advanced-headers":"","custom-layouts":"custom-layouts","spacing":"spacing","sticky-header":"","scroll-to-top":"","transparent-header":"","typography":"typography","woocommerce":"","edd":"","nav-menu":"","all":"all","site-layouts":""}'
    wp option update astra-settings --format=json '{"astra-addon-auto-version":"2.1.4","theme-auto-version":"2.1.3","_astra_pb_compatibility_completed":true,"site-content-layout":"plain-container","site-sidebar-layout":"no-sidebar","footer-sml-section-1-credit":"Copyright \u00a9 [current_year] [site_title]","footer-sml-section-2":"custom","footer-sml-section-2-credit":"<a href=\"\/privacy-policy\">Privacy Policy<\/a> | <a href=\"\/terms-of-use\">Terms of Use<\/a>","font-size-footer-content":{"desktop":".75","tablet":"","mobile":"","desktop-unit":"em","tablet-unit":"px","mobile-unit":"px"},"site-content-width":1200,"is_addon_queue_running":false,"is_theme_queue_running":false,"submenu-open-below-header":false,"theme-color":"#001080","link-color":"#00a323","body-font-family":"'Open Sans', sans-serif","body-font-weight":"400","display-site-title":false,"header-layouts":"header-main-layout-1","disable-primary-nav":false,"body-font-variant":"","font-size-body":{"desktop":"16","tablet":"","mobile":"","desktop-unit":"px","tablet-unit":"px","mobile-unit":"px"},"font-weight-h1":"800","font-weight-h2":"700","font-weight-h3":"600","font-weight-h4":"500","font-size-h6":{"desktop":"16","tablet":"","mobile":"","desktop-unit":"px","tablet-unit":"px","mobile-unit":"px"},"headings-font-family":"'Montserrat', sans-serif","headings-font-weight":"400","text-color":"#54595f","site-layout-outside-bg-obj":{"background-color":"#f7f7f7","background-image":"","background-repeat":"repeat","background-position":"center center","background-size":"auto","background-attachment":"scroll"},"link-h-color":"#4dbf65","content-bg-obj":{"background-color":"#f7f7f7","background-image":"","background-repeat":"repeat","background-position":"center center","background-size":"auto","background-attachment":"scroll"},"button-color":"","button-bg-color":"#e10000","button-bg-h-color":"#9e0000","h1-color":"#001080","h2-color":"#001080","h3-color":"#001080","h4-color":"#334099","h5-color":"#334099","h6-color":"#3b3e43","ast-header-responsive-logo-width":{"desktop":"300","tablet":"","mobile":""},"font-weight-h5":"400","font-weight-h6":"400"}'
}
function install_config_generatepress(){ echo "Installing and Configuring Generatepress"
    wp theme install generatepress --activate
    wp plugin install $dl_generatepress_pro --activate
    wp config set GENERATE_HOOKS_DISALLOW_PHP true
    wp option update gen_premium_license_key ""
    wp option update gen_premium_license_key_status valid
    wp option update generate_package_colors 'activated' && wp option update generate_package_typography 'activated' && wp option update generate_package_copyright 'activated' && wp option update generate_package_hooks 'activated' && wp option update generate_package_import_export 'activated' && wp option update generate_package_spacing 'activated'
    wp option update generate_settings --format=json '{"layout_setting":"no-sidebar"}'
    wp option update theme_mods_generatepress --format=json '{"generate_copyright":"Copyright %copy%  %current_year% Peak Performance Digital | <a href=\"\\privacy-policy\">Privacy Policy<\/a> | <a href=\"\\terms-of-use\">Terms of Use<\/a>"}'
}
function install_config_elementor(){ echo "Installing and configuring elementor"
    wp plugin install elementor $dl_elementor_pro --activate
    wp elementor-pro license activate ""
    wp option update elementor_disable_color_schemes yes
    wp option update elementor_disable_typography_schemes yes
    wp option update elementor_allow_svg 1
    wp option update _elementor_general_settings --format=json '{"default_generic_fonts":"Sans-serif","global_image_lightbox":"yes","container_width":"1200"}'
}
function install_config_colorpalette(){ echo "Installing and configuring color palette"
    wp plugin install kt-tinymce-color-grid --activate
    wp option update kt_color_grid_customizer 1
    wp option update kt_color_grid_elementor 1
    wp option update kt_color_grid_gutenberg 1
    wp option update kt_color_grid_visual 1
    wp option update kt_color_grid_css_vars 1
    wp option update kt_color_grid_palette --format=json '[{"color":"#000B5A","hex":"#000B5A","name":"Primary Shade","alpha":100,"index":"1","status":1,"type":1},{"color":"#001080","hex":"#001080","name":"Primary Color","alpha":100,"index":"6","status":1,"type":1},{"color":"#334099","hex":"#334099","name":"Primary Tint","alpha":100,"index":"2","status":1,"type":1},{"color":"#007219","hex":"#007219","name":"Secondary Shade","alpha":100,"index":"3","status":1,"type":1},{"color":"#00A323","hex":"#00A323","name":"Secondary Color","alpha":100,"index":"8","status":1,"type":1},{"color":"#4DBF65","hex":"#4DBF65","name":"Secondary Tint","alpha":100,"index":"4","status":1,"type":1},{"color":"#9E0000","hex":"#9E0000","name":"Tertiary Shade","alpha":100,"index":"5","status":1,"type":1},{"color":"#E10000","hex":"#E10000","name":"Tertiary Color","alpha":100,"index":"7","status":1,"type":1},{"color":"#EA4D4D","hex":"#EA4D4D","name":"Tertiary Tint","alpha":100,"index":"8","status":1,"type":1},{"color":"#3B3E43","hex":"#3B3E43","name":"Body Shade","alpha":100,"index":"9","status":1,"type":1},{"color":"#54595F","hex":"#54595F","name":"Body Text Color","alpha":100,"index":"10","status":1,"type":1},{"color":"#878B8F","hex":"#878B8F","name":"Body Tint","alpha":100,"index":"11","status":1,"type":1},{"color":"#ADADAD","hex":"#ADADAD","name":"Background Shade","alpha":100,"index":"12","status":1,"type":1},{"color":"#F7F7F7","hex":"#F7F7F7","name":"Background Color","alpha":100,"index":"13","status":1,"type":1},{"color":"#F9F9F9","hex":"#F9F9F9","name":"Background Tint","alpha":100,"index":"14","status":1,"type":1},{"color":"#000000","hex":"#000000","name":"Black","alpha":100,"index":"1","status":1,"type":1},{"color":"#4D4D4D","hex":"#4D4D4D","name":"Dark Gray","alpha":100,"index":"15","status":1,"type":1},{"color":"#808080","hex":"#808080","name":"Medium Gray","alpha":100,"index":"16","status":1,"type":1},{"color":"#B3B3B3","hex":"#B3B3B3","name":"Light Gray","alpha":100,"index":"17","status":1,"type":1},{"color":"#FFFFFF","hex":"#FFFFFF","name":"White","alpha":100,"index":"2","status":1,"type":1}]'
}
function install_style_kit(){ echo "Installing and configuringing AnalogWP Style Kit"
    wp plugin install analogwp-templates $dl_style_kit --activate
    wp option update ang_options --format=json '{"ang_license_key_status":"valid","ang_license_key":""}'
}
function install_config_oxygen(){ echo "Install Oxygen Builder"
    wp plugin install $dl_oxygen_base $dl_oxygen_gutenberg --activate
    wp option update oxygen_vsb_enable_default_designsets "false"
    wp option update oxygen_vsb_enable_connection "false"
    wp option update oxygen_vsb_enable_selector_detector "true"
    wp option update oxygen_license_key ""
    wp option update oxygen_license_status "valid"
    wp option update oxygen_gutenberg_license_key ""
    wp option update oxygen_gutenberg_license_status "valid"
    wp option update oxygen-vsb-activated 1
    wp option update oxygen_vsb_ignore_post_type_acf-field "true"
    wp option update oxygen_vsb_ignore_post_type_acf-field-group "true"
    wp option update oxygen_vsb_ignore_post_type_itsec-dash-card "true"
    wp option update oxygen_vsb_ignore_post_type_itsec-dashboard "true"
    wp option update oxygen_vsb_ignore_post_type_oxy_user_library "true"
    wp option update oxygen_vsb_ignore_post_type_seopress_bot "true"
    wp option update oxygen_vsb_ignore_post_type_seopress_schemas "true"
    wp option update oxygen_vsb_ignore_post_type_user_request "true"
    wp option update oxygen_vsb_ignore_post_type_wp_block "true"
    wp option update oxygen_vsb_global_colors --format=json '{"colorsIncrement":12,"setsIncrement":3,"colors":[{"id":90,"name":"Pure White","value":"#ffffff","set":3},{"id":93,"name":"Gray 30","value":"#b3b3b3","set":3},{"id":95,"name":"Gray 50","value":"#808080","set":3},{"id":97,"name":"Gray 70","value":"#4c4c4c","set":3},{"id":100,"name":"Pure Black","value":"#000000","set":3}],"sets":[{"id":0,"name":"Global Colors"},{"id":3,"name":"Default Colors"}]}'
}

function install_config_oxygen_addons(){ echo "Installing Oxygen Addons"
    wp plugin install $dl_oxy_toolbox --activate
        wp option update oxy_toolbox_license_key ""
        wp option update oxy_toolbox_license_status "valid"
        wp option update oxy_toolbox_class_act_ 1
        wp option update oxy_toolbox_class_cleaner_ 1
        wp option update oxy_toolbox_emmet_ 1
        wp option update oxy_toolbox_conditions_ 1
        wp option update oxy_toolbox_conditions_post_id_in_array "true"
        wp option update oxy_toolbox_conditions_at_least_one_search_result "true"
        wp option update oxy_toolbox_conditions_mobile_detect "true"
        wp option update oxy_toolbox_conditions_is_homepage "true"
        wp option update oxy_toolbox_conditions_archive_type "true"
        wp option update oxy_toolbox_conditions_body_class "true"
        wp option update oxy_toolbox_conditions_browser_detect "true"
        wp option update oxy_toolbox_conditions_is_archive "true"
        wp option update oxy_toolbox_conditions_post_has_tags "true"
        wp option update oxy_toolbox_conditions_published_during_last "true"
        wp option update oxy_toolbox_conditions_is_blog "true"
        wp option update oxy_toolbox_editor_tweaks_ 1
        wp option update oxy_toolbox_editor_tweaks_back_to_wp_additions "true"
        wp option update oxy_toolbox_editor_tweaks_compact_view_for_element_buttons "true"
        wp option update oxy_toolbox_editor_tweaks_currently_editing "true"
        wp option update oxy_toolbox_editor_tweaks_css_tweaks "true"
        wp option update oxy_toolbox_editor_tweaks_wider_library_flyout_panel "true"
        wp option update oxy_toolbox_editor_tweaks_copy_selector "true"
        wp option update oxy_toolbox_essentials_ 1
        wp option update oxy_toolbox_fullscreen_ 0
        wp option update oxy_toolbox_fullscreen_mode 1
        wp option update oxy_toolbox_fullscreen_hotkey 17
        wp option update oxy_toolbox_gutenberg_ 1
        wp option update oxy_toolbox_gutenberg_full_width_editor ""
        wp option update oxy_toolbox_gutenberg_disable_editor_fullscreen_by_default "true"
        wp option update oxy_toolbox_gutenberg_disable_welcome_guide "true"
        wp option update oxy_toolbox_gutenberg_disable_nux "true"
        wp option update oxy_toolbox_navigator_ 1
        wp option update oxy_toolbox_navigator_fluentforms "true"
        wp option update oxy_toolbox_navigator_acf "true"
        wp option update oxy_toolbox_navigator_oxygen "true"
        wp option update oxy_toolbox_navigator_templates "true"
        wp option update oxy_toolbox_navigator_pages_oxygen "true"
        wp option update oxy_toolbox_navigator_advanced_scripts "true"
        wp option update oxy_toolbox_offline_mode_ 1
        wp option update oxy_toolbox_open_external_links_new_tab_ 1
        wp option update oxy_toolbox_reading_progress_bar_ 1
        wp option update oxy_toolbox_remove_themes_theme_editor_admin_menu_ 1
        wp option update oxy_toolbox_seopress_ 1
        wp option update oxy_toolbox_scripts_ 1
        wp option update oxy_toolbox_text_edit_ 1
        wp option update oxy_toolbox_toc_ 1
        wp option update oxy_toolbox_revisions_ 1
        wp option update oxy_toolbox_revisions_max 99
        wp option update oxy_toolbox_wordpress_ 1
        wp option update oxy_toolbox_wordpress_disable_auto_updates_ui "true"
        wp option update oxy_toolbox_wordpress_disable_xml_sitemap_oxygen_templates "true"
        wp option update oxy_toolbox_sseditor_ 1
    wp plugin install $dl_oxy_extras --activate
        wp option update oxy_extras_license_key ""
        wp option update oxy_extras_license_status "valid"
        wp option update oxy_extras_adjecent_posts 1
        wp option update oxy_extras_copyright_text 1
    wp plugin install $dl_hydrogen --activate
        wp option update hydrogen-settings --format=json '{"contextMenu":{"enabled":true,"items":{"duplicate":true,"copy":true,"copyStyle":true,"copyConditions":true,"cut":true,"paste":true,"saveReusable":true,"saveBlock":true,"wrap":true,"wrapLink":true,"showConditions":true,"rename":true,"changeId":true,"delete":true}},"clipboard":{"enabled":true,"colorSet":"Copied Colors","folder":"Copied Classes","keepActiveComponent":false,"flashCopiedComponent":true,"processMediaImages":true},"shortcuts":{"enabled":true,"hotkeys":{"componentBrowser":{"ctrl":true,"alt":false,"shift":false,"key":"a"},"copy":{"ctrl":true,"alt":false,"shift":false,"key":"c"},"copyStyle":{"ctrl":true,"alt":false,"shift":true,"key":"c"},"copyConditions":{"ctrl":false,"alt":false,"shift":false,"key":""},"cut":{"ctrl":true,"alt":false,"shift":false,"key":"x"},"duplicate":{"ctrl":true,"alt":false,"shift":false,"key":"d"},"savePage":{"ctrl":true,"alt":false,"shift":false,"key":"s"},"delete":{"ctrl":false,"alt":false,"shift":false,"key":"delete"},"rename":{"ctrl":false,"alt":false,"shift":false,"key":"f2"},"changeId":{"ctrl":true,"alt":false,"shift":false,"key":"f2"},"moveUp":{"ctrl":true,"alt":false,"shift":false,"key":"arrowup"},"moveDown":{"ctrl":true,"alt":false,"shift":false,"key":"arrowdown"},"wrap":{"ctrl":true,"alt":false,"shift":true,"key":"w"},"wrapLink":{"ctrl":false,"alt":false,"shift":false,"key":""},"setConditions":{"ctrl":false,"alt":false,"shift":false,"key":""},"clearConditions":{"ctrl":false,"alt":false,"shift":false,"key":""},"activateParent":{"ctrl":true,"alt":false,"shift":false,"key":"p"},"editContent":{"ctrl":true,"alt":false,"shift":false,"key":"e"},"setMediaPrevious":{"ctrl":true,"alt":false,"shift":false,"key":"arrowleft"},"setMediaNext":{"ctrl":true,"alt":false,"shift":false,"key":"arrowright"},"setMediaDefault":{"ctrl":false,"alt":false,"shift":false,"key":""},"setMediaPageWidth":{"ctrl":false,"alt":false,"shift":false,"key":""},"setMediaTablet":{"ctrl":false,"alt":false,"shift":false,"key":""},"setMediaLandscape":{"ctrl":false,"alt":false,"shift":false,"key":""},"setMediaPortrait":{"ctrl":false,"alt":false,"shift":false,"key":""},"addSection":{"ctrl":false,"alt":false,"shift":true,"key":"s"},"addButton":{"ctrl":false,"alt":false,"shift":true,"key":"b"},"addColumns":{"ctrl":false,"alt":false,"shift":true,"key":"c"},"addDiv":{"ctrl":false,"alt":false,"shift":true,"key":"d"},"addHeading":{"ctrl":false,"alt":false,"shift":true,"key":"h"},"addImage":{"ctrl":false,"alt":false,"shift":true,"key":"i"},"addCode":{"ctrl":false,"alt":false,"shift":true,"key":"k"},"addLink":{"ctrl":false,"alt":false,"shift":true,"key":"l"},"addRepeater":{"ctrl":false,"alt":false,"shift":true,"key":"r"},"addText":{"ctrl":false,"alt":false,"shift":true,"key":"t"},"addVideo":{"ctrl":false,"alt":false,"shift":true,"key":"v"},"addLinkWrapper":{"ctrl":false,"alt":false,"shift":false,"key":""},"addIcon":{"ctrl":false,"alt":false,"shift":false,"key":""},"addShortcode":{"ctrl":false,"alt":false,"shift":false,"key":""},"addEasyPosts":{"ctrl":false,"alt":false,"shift":false,"key":""},"addGallery":{"ctrl":false,"alt":false,"shift":false,"key":""},"addModal":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabBackground":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabPosition":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabLayout":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabTypography":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabBorders":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabEffects":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabCustomCSS":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchAdvancedTabJavascript":{"ctrl":false,"alt":false,"shift":false,"key":""},"switchCodeBlockTabs":{"ctrl":false,"alt":false,"shift":false,"key":""},"toggleLeftSidebar":{"ctrl":false,"alt":false,"shift":false,"key":""},"toggleStructurePanel":{"ctrl":false,"alt":false,"shift":false,"key":""},"toggleSettingsPanel":{"ctrl":false,"alt":false,"shift":false,"key":""},"toggleStylesheetsPanel":{"ctrl":false,"alt":false,"shift":false,"key":""},"toggleSelectorsPanel":{"ctrl":false,"alt":false,"shift":false,"key":""},"manageGlobalColors":{"ctrl":false,"alt":false,"shift":false,"key":""},"manageGlobalFonts":{"ctrl":false,"alt":false,"shift":false,"key":""},"manageGlobalBreakpoints":{"ctrl":false,"alt":false,"shift":false,"key":""},"manageGlobalLinks":{"ctrl":false,"alt":false,"shift":false,"key":""},"manageGlobalHeadings":{"ctrl":false,"alt":false,"shift":false,"key":""},"manageGlobalBodyText":{"ctrl":false,"alt":false,"shift":false,"key":""},"openFrontend":{"ctrl":false,"alt":false,"shift":false,"key":""},"openBackend":{"ctrl":false,"alt":false,"shift":false,"key":""}}},"conditionsEnhancer":{"enabled":true},"structureEnhancer":{"enabled":true,"compact":true,"icons":true,"openOnLoad":false,"expandAll":false,"width":""},"contentEditorEnhancer":{"enabled":true},"advancedStylesReset":{"enabled":true},"disableEditLocking":{"enabled":false},"cssCacheRegeneration":{"enabled":false},"sandbox":{"enabled":false}}'
}
function install_config_advanced_scripts(){ echo "Installing Advanced Scripts"
    wp plugin install $dl_advanced_scripts --activate
}
function install_config_acf(){ echo "Installing Advanced Custom Fields"
    wp plugin install $dl_advanced_custom_fields custom-post-type-ui --activate
    wp option update acf_pro_license ""
}

function install_config_gravity_forms(){ echo "Installing Gravity Forms"
    wp plugin install $dl_gravity_forms gravityformscli --activate
    wp gf license update ""
}
function install_config_happy_files(){ echo "Installing HappyFiles"
    wp plugin install $dl_happy_files --activate
    wp option update happyfiles_license_key ""
    wp option update happyfiles_hide_first_use_notification 1
    wp option update happyfiles_hide_rate_us_notification 1
}

##############################
###### Helper Functions ######
##############################
function get_domain_fqdn(){
    site_fqdn=${PWD%"/htdocs"}; site_fqdn=${site_fqdn#$HOME"/sites/"}
    domain_identifier=${site_fqdn%%.*}
}
function get_core_input(){
    echo "Site Name ("$(wp option get blogname)"):" ; read site_name ; site_name="${site_name:=$(wp option get blogname)}"
    echo "Site Description ("$(wp option get blogdescription)"):" ; read site_description ; site_description="${site_description:=$(wp option get blogdescription)}"
    echo "Admin Email Address ("$(wp option get admin_email)"):" ; read admin_email_address; admin_email_address="${admin_email_address:=$(wp option get admin_email)}"
}
function get_backup_input(){
    select_server_type
    echo "Backup Notification Email Address (Backup@PeakPerformanceDigital.com):"; read backup_email_address; backup_email_address="${backup_email_address:="[[replaceme]]"}"
}
function install_config_caching_plugin(){
    case ${server_type,,} in
        apache)
            install_config_wprocket
        ;;
        nginx)
            ## to do add nginx plugin
        ;;
        openlitespeed)
            install_config_litespeedcache
        ;;
        *)
            echo "I don\'t recognize that input"
            select_server_type
        ;;
    esac
}

##############################
###### Drive the Script ######
##############################
function select_server_type(){
    echo "Select the server type: ([A}pache, [N]ginx, [O]penLiteSpeed)"; read server_selection
    case ${server_selection,,} in
        a)
            server_type="Apache"
        ;;
        n)
            server_type="Nginx"
        ;;
        o)
            server_type="OpenLiteSpeed"
        ;;
        *)
            echo "I don\'t recognize that input"
            select_server_type
        ;;
    esac
}

function select_installation(){
    echo "Installation Type? [C]ore, [B]ase, [I]ndividual, [S]ets, Exit"; read install_type
    case ${install_type,,} in
        c)
            get_core_input
            do_core_settings
        ;;
        b)
            get_core_input
            get_backup_input
            do_core_settings
            do_base_settings
        ;;
        i)
            do_get_individual
        ;;
        s)
            do_get_sets
        ;;
        exit)
            echo "Finished Installing Packages"
            exit
        ;;
        *)
            echo "I don\'t recognize that input"
            select_installation
        ;;
    esac
}

function do_core_settings(){
    wp core update
    wp_settings_general
    wp_settings_system
    wp_settings_pages_posts
    wp_settings_reading
    wp_settings_discussion
    wp_settings_media
    wp_settings_permalinks
    wp_themes_remove_unneeded
    wp_plugins_remove_unneeded
    wp_user_admin_defaults
    wp_roles_create_defaults
}
function do_base_settings(){
    install_config_updraft
    install_config_fluentsmtp
    install_config_ithemessecurity
    install_config_seopress
    install_config_shortpixel
    install_config_caching_plugin
    install_mainwp
}

function do_get_individual(){
    echo "Select item to install or Exit to quit:"; 
    echo "0: Back to main menu"
    echo "1: Fluent SMTP"
    echo "2: UpdraftPlus Ultimate"
    echo "3: SEOPress Professional"
    echo "4: ithemes Security Professional"
    echo "5: ShortPixel"
    echo "6: LiteSpeed Cache"
    echo "7: WP Rocket"
    echo "8: Oxygen Builder"
    echo "9: Oxygen Addons"
    echo "10: Astra Theme"
    echo "11: GeneratePress Theme"
    echo "12: Elementor"
    echo "13: Color Palette"
    echo "14: Style Kits for Elementor"
    echo "15: Advanced Custom Fields"
    echo "16: Gravity Forms"
    echo "17: Advanced Scripts"
    echo "18: Happy Files"
    read choice_installation_item
    case ${choice_installation_item,,} in 
        0)
            echo "Returning to main menu"
            select_installation
        ;;
        1)
            install_config_fluentsmtp
        ;;
        2)
            get_backup_input
            install_config_updraft
        ;;
        3)
            install_config_seopress
        ;;
        4)
            install_config_ithemessecurity
        ;;
        5)
            install_config_shortpixel
        ;;
        6)
            install_config_litespeedcache
        ;;
        7)
            install_config_wprocket
        ;;
        8)
            install_config_oxygen
        ;;
        9)
            install_config_oxygen_addons
        ;;
        10)
            install_config_astra
        ;;
        11)
            install_config_generatepress
        ;;
        12)
            install_config_elementor
        ;;
        13)
            install_config_colorpalette
        ;;
        14)
            install_style_kit
        ;;
        15)
            install_config_acf
        ;;
        16)
            install_config_gravity_forms
        ;;
        17)
            install_config_advanced_scripts
        ;;
        18)
            install_config_happy_files
        ;;
        exit)
            echo "Finished Installing Selected Items"
            exit
        ;;
        *)
            echo "That input is not valid"
            do_get_individual
        ;;
    esac 
    do_get_individual
}

function do_get_sets(){
    echo "Select set to install or Exit to quit:"; 
    echo "0: Back to main menu"
    echo "1: Core Settings, Base Apps, & Oxygen Builder and Addons"
    read choice_installation_set
    case ${choice_installation_set,,} in 
        0)
            echo "Returning to main menu"
            select_installation
        ;;
        1)
            get_core_input
            get_backup_input
            do_core_settings
            do_base_settings
            install_config_oxygen
            install_config_advanced_scripts
            install_config_oxygen_addons
        ;;
        exit)
            echo "Finished Installing Selected Items"
            exit
        ;;
        *)
            echo "That input is not valid"
            do_get_sets
        ;;
    esac 
}

##############################
###### Start the Script ######
##############################

initialize_variables
get_domain_fqdn
select_installation

echo "All Done"
