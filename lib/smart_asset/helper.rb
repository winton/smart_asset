class SmartAsset
  module Helper
    
    def javascript_include_merged(*javascripts)
      output = javascript_paths(*javascripts).collect { |js|
        "<script src=\"#{js}\" type=\"text/javascript\"></script>"
      }.join("\n")
      defined?(Rails) && Rails.version[0..0] == '3' ? output.html_safe : output
    end
    
    def stylesheet_link_merged(*stylesheets)
      output = stylesheet_paths(*stylesheets).collect { |css|
        "<link href=\"#{css}\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
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