require 'cocoapods'
require 'cocoapods-autoclean/sort'

module AutocleanModule
  class Autocleaner
    attr_reader :context
    
    attr_reader :cache

    attr_reader :current_prj_dep_hash

    attr_reader :release_descs_hash

    def initialize(context)
      @context = context
      @cache = Pod::Downloader::Cache.new(Pod::Config.instance.cache_root + 'Pods')
      @current_prj_dep_hash = Hash.new
    end
  
    def prepare
      targets = context.umbrella_targets
      targets.each do |target|
        specs = target.specs
        specs.each do |spec|
          if current_prj_dep_hash[spec.name] == nil 
            current_prj_dep_hash[spec.name] = {spec.version.version => spec.version.version}
            next
          end

          current_prj_dep_hash[spec.name].store(spec.version.version, spec.version.version)
        end
      end
      # read_current_prj_hash
      @release_descs_hash = @cache.cache_descriptors_per_pod
    end

    def read_current_prj_hash
      current_folder_path =Pathname.new(File.dirname(__FILE__)).parent
      path = current_folder_path + "current_json.json"
      pn_path = Pathname.new(path)
      string = pn_path.read.strip
      hash = JSON.parse string
      current_prj_dep_hash = hash
    end

    def autoclean
        t = Time.now
        prepare
        Pod::UI.puts "\nAuto Clean Release Completed in #{Time.now - t} seconds" if clean_release
        Pod::UI.puts "\nAuto Clean External Completed in #{Time.now - t} seconds" if clean_external
    end
  
    def clean_release
      release_pods_pn = @cache.root + 'Release'
      need_clean = false
      max_count = Pod::Config.instance.cache_max_count
      return false if !FileTest.exist?(release_pods_pn)
      
      release_pods_pn.each_child do |pn|
        dirs = Dir[pn + '*']
        next if dirs.length <= max_count
        filename = pn.basename.to_s

        pns = dirs.map{|dir| Pathname.new(dir)}        
        curent_dep_version_hash = current_prj_dep_hash[filename]
        selected_pns = pns

        selected_pns = AutocleanModule::Select.select(pns, curent_dep_version_hash) if curent_dep_version_hash != nil && !curent_dep_version_hash.empty?
        
        next unless selected_pns != nil && !selected_pns.empty?

        sorted_pns = AutocleanModule::Sort.sort_pns(selected_pns)
        
        next if sorted_pns.size < max_count
        
        need_clean_pns = sorted_pns[max_count, sorted_pns.size - 1]
        size = need_clean_pns.size
        next if size == 0

        need_clean = true if !need_clean
        need_clean_pns.each do |will_remove_pn|
          remove(will_remove_pn)
        end
      end

      need_clean
    end
  
    def clean_external
      # puts "clean_external"
    end

    def remove(pn)
      Pod::UI.puts "Removing #{pn}"
      cache_desc = find_pod_caches(pn)
      remove_cache(cache_desc, pn)
    end

    def just_remove(pn)
       FileUtils.rm_rf(pn)
    end

    def remove_cache(desc, pn)
      if desc != nil  
        FileUtils.rm(desc[:spec_file]) if FileTest.exist?(desc[:spec_file])
        FileUtils.rm_rf(desc[:slug])
      end
      just_remove(pn)
    end

    def find_pod_caches(pn)
      spec_name = pn.dirname.basename.to_s
      version = AutocleanModule::SpecVersion.version_pn(pn)
      release_desc_list = release_descs_hash[spec_name]
      return nil if release_desc_list == nil || release_desc_list.empty?
      release_version_desc_hash = Hash.new()
      release_desc_list.each do |desc|
        desc_version = desc[:version].to_s
        release_version_desc_hash[desc_version] = desc
      end
      release_version_desc_hash[version]
    end
  end
end
