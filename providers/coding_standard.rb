#
# Cookbook Name:: phpcs
# Provider:: coding_standard
#
# Copyright (c) 2016, David Joos
#

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

action :install do
  Chef::Log.info 'Installing coding standard #{new_resource.name}'

  case node['phpcs']['install_method']
  when 'pear'
    php_dir = `pear config-get php_dir`.strip
    standards_dir = "#{php_dir}/PHP/CodeSniffer/Standards"
  when 'composer'
    standards_dir = "#{node['phpcs']['install_dir']}/vendor/squizlabs/php_codesniffer/CodeSniffer/Standards"
  end

  target = "#{standards_dir}/#{new_resource.name}"

  git target do
    repository new_resource.repository
    reference new_resource.reference
    action :sync
    only_if { Dir.exist?(standards_dir) }
    notifies :run, 'execute[filter-subdirectory]', :immediately
  end

  execute 'filter-subdirectory' do
    cwd target
    command "git filter-branch --subdirectory-filter -f #{new_resource.subdirectory}"
    not_if { new_resource.subdirectory.nil? }
    action :nothing
  end

  new_resource.updated_by_last_action(true)
end
