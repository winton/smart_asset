class SmartAsset
  module Helper
    
    def javascript_include_merged(*javascripts)
      append = SmartAsset.append_random ? "?#{rand.to_s[2..-1]}" : ''
      output = javascript_paths(*javascripts).collect { |js|
        "<script src=\"#{SmartAsset.prepend_asset_host js}#{append}\"></script>"
      }.join("\n")
      defined?(Rails) && Rails.version[0..0] == '3' ? output.html_safe : output
    end
    
    def stylesheet_link_merged(*stylesheets)
      append = SmartAsset.append_random ? "?#{rand.to_s[2..-1]}" : ''
      options = stylesheets.last.is_a?(::Hash) ? stylesheets.pop : {}
      options[:media] ||= 'screen'
      output = stylesheet_paths(*stylesheets).collect { |css|
        "<link href=\"#{SmartAsset.prepend_asset_host css}#{append}\" media=\"#{options[:media]}\" rel=\"stylesheet\" />"
      }.join("\n")
      defined?(Rails) && Rails.version[0..0] == '3' ? output.html_safe : output
    end
    
    def javascript_paths(*javascripts)
      javascripts.collect { |js| SmartAsset.paths('javascripts', js) }.flatten.uniq
    end
    
    def stylesheet_paths(*stylesheets)
      stylesheets.collect { |css| SmartAsset.paths('stylesheets', css) }.flatten.uniq
    end
  end
end