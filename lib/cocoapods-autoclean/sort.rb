require 'cocoapods'
module AutocleanModule
    class Sort
        class << self
            def sort_spec(specs)
                sorted_spec = specs.sort { |spec1, spec2|  
                    version1 = spec1.version.version
                    version2 = spec2.version.version

                    version1s = version1.split('.')
                    version2s = version2.split('.')

                    if version1 == version2
                        0
                    elsif version1s.size == version2s.size
                        calculate_version_count_equal(version1s, version2s)
                    else
                        calculate_version_count_not_equal(version1s, version2s)
                    end
                }

                sorted_spec
            end

            def sort_pns(pns)
                sorted_pns = pns.sort { |pn1, pn2|  
                    version1 = pn1.basename.to_s.split('-').first
                    version2 = pn2.basename.to_s.split('-').first

                    version1s = version1.split('.')
                    version2s = version2.split('.')

                    if version1 == version2
                        0
                    elsif version1s.size == version2s.size
                        type = calculate_version_count_equal(version1s, version2s)
                        type
                    else
                        type = calculate_version_count_not_equal(version1s, version2s)
                        type
                    end
                }
                sorted_pns
            end

            private
            # <=>
            def calculate_version_count_equal(version1s, version2s)
                count = version1s.size

                type = 0
                (0..count).each do |i|
                    v1 = version1s[i]
                    v2 = version2s[i] 

                    next if v1 == v2

                    return v2.to_f <=> v1.to_f
                end
            end

            # 
            def calculate_version_count_not_equal(version1s, version2s)
                count = [version1s.size, version2s.size].max

                type = 0
                (0..count).each do |i|
                    v1 = version1s[i]
                    v2 = version2s[i]

                    break if v1.nil?
                    break if v2.nil?
                    next if v1 == v2

                    type = v2.to_f <=> v1.to_f
                    break if v2.to_f != v1.to_f
                end

                type
            end
        end
    end

    class SpecVersion
        class << self
            def version_pn(pn)
                filename = pn.basename.to_s
                verion = version_filename(filename)
                verion
            end

            def version_filename(filename)
                sub_filenames = filename.split('-')
                sub_filenames[0] 
            end
        end
    end

    class Select
        class << self
            def select(pns, curent_dep_version_hash)
                filter_pns = pns.select { |sub_pn|  
                    sub_filename = sub_pn.basename.to_s
                    sub_filenames = sub_filename.split('-')
                    version = sub_filenames[0]
                    if curent_dep_version_hash[version] != nil
                      false
                    else
                      true
                    end
                }
                filter_pns
            end
        end
    end
end